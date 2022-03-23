import 'dart:convert';
import 'dart:io';

import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Controller/EditProfileScreenController.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

import '../Common/Extension.dart';
import '../Common/sToken.dart';
import '../Model/JsonValueModel.dart';
import '../Model/UserModel.dart';
import 'package:cartoonizer/api.dart';
import 'package:cartoonizer/Common/utils.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final EditProfileScreenController controller = Get.put(EditProfileScreenController());
  var imagePicker;
  final nameController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    Get.reset(clearRouteBindings: true);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    imagePicker = new ImagePicker();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.BackgroundColor,
      body: SafeArea(
        child: FutureBuilder(
          future: _getData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return Obx(
                () => LoadingOverlay(
                  isLoading: controller.isLoading.value,
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 1.h, left: 5.w, right: 5.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () => {Navigator.pop(context)},
                              child: Image.asset(
                                ImagesConstant.ic_back_dark,
                                height: 10.w,
                                width: 10.w,
                              ),
                            ),
                            TitleTextWidget(StringConstant.edit_profile, ColorConstant.BtnTextColor, FontWeight.w600, 14.sp),
                            SizedBox(
                              height: 10.w,
                              width: 10.w,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(5.w),
                                child: Card(
                                  shadowColor: Color.fromRGBO(0, 0, 0, 0.5),
                                  elevation: 2.h,
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(3.w),
                                  ),
                                  child: Stack(
                                    children: [
                                      Image.asset(
                                        ImagesConstant.ic_round_top,
                                        width: 100.w,
                                        height: 20.h,
                                        fit: BoxFit.fill,
                                      ),
                                      Column(
                                        children: [
                                          Center(
                                            child: Container(
                                              width: 35.w,
                                              height: 35.w,
                                              margin: EdgeInsets.only(top: 10.h),
                                              child: Stack(
                                                children: [
                                                  Card(
                                                    elevation: 2.h,
                                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.w)),
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        border: Border.all(color: ColorConstant.White, width: 2.w),
                                                      ),
                                                      child: ClipRRect(
                                                        borderRadius: BorderRadius.circular(50.w),
                                                        child: (controller.isPhotoSelect.value)
                                                            ? Obx(
                                                                () => Image.file(
                                                                  controller.image.value as File,
                                                                  width: 40.w,
                                                                  height: 40.w,
                                                                  fit: BoxFit.fill,
                                                                  errorBuilder: (context, error, stackTrace) {
                                                                    return Image.asset(
                                                                      ImagesConstant.ic_demo1,
                                                                      fit: BoxFit.fill,
                                                                      width: 40.w,
                                                                      height: 40.w,
                                                                    );
                                                                  },
                                                                ),
                                                              )
                                                            : Image.network(
                                                                (snapshot.hasData) ? (snapshot.data as UserModel).avatar : "",
                                                                width: 40.w,
                                                                height: 40.w,
                                                                fit: BoxFit.fill,
                                                                errorBuilder: (context, error, stackTrace) {
                                                                  return Image.asset(
                                                                    ImagesConstant.ic_demo1,
                                                                    fit: BoxFit.fill,
                                                                    width: 40.w,
                                                                    height: 40.w,
                                                                  );
                                                                },
                                                              ),
                                                      ),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    bottom: 1.h,
                                                    right: 2.w,
                                                    child: GestureDetector(
                                                      onTap: () async {
                                                        showCameraDialog(context);
                                                      },
                                                      child: SimpleShadow(
                                                        child: Image.asset(
                                                          ImagesConstant.ic_camera_upload,
                                                          height: 10.w,
                                                          width: 10.w,
                                                        ),
                                                        sigma: 10,
                                                        opacity: 0.2,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 2.h,
                                          ),
                                          TitleTextWidget((snapshot.hasData) ? (snapshot.data as UserModel).email : "", ColorConstant.LightTextColor, FontWeight.w400, 14.sp),
                                          SizedBox(
                                            height: 2.h,
                                          ),
                                          SimpleTextInputWidget(StringConstant.name_hint, ColorConstant.HintColor, FontWeight.w400, 12.sp, TextInputAction.done,
                                              TextInputType.emailAddress, false, nameController),
                                          SizedBox(
                                            height: 4.h,
                                          ),
                                          GestureDetector(
                                            onTap: () async {
                                              if (nameController.text.trim().isEmpty) {
                                                CommonExtension().showToast(StringConstant.name_validation);
                                              } else {
                                                FocusManager.instance.primaryFocus?.unfocus();
                                                controller.changeIsLoading(true);
                                                var sharedPrefs = await SharedPreferences.getInstance();
                                                final headers = {"Content-type": "application/json", "cookie": "sb.connect.sid=${sharedPrefs.getString("login_cookie")}"};

                                                List<JsonValueModel> params = [];
                                                var name = nameController.text.toString();
                                                var avatar = controller.imageUrl.value;

                                                params.add(JsonValueModel("name", name));
                                                params.add(JsonValueModel("avatar", avatar));
                                                params.sort();

                                                var body = jsonEncode(<String, dynamic>{
                                                  'name': name,
                                                  'avatar': avatar,
                                                  's': sToken(params),
                                                });

                                                final updateProfileResponse = await post(Uri.parse("https://socialbook.io/api/user/update"), body: body, headers: headers);

                                                saveUser({
                                                  'name': name,
                                                  'avatar': avatar,
                                                });

                                                if (updateProfileResponse.statusCode == 200) {
                                                  CommonExtension().showToast("Profile update successfully!!");
                                                  Navigator.pop(context, false);
                                                } else {
                                                  CommonExtension().showToast("Oops something went wrong!!");
                                                }

                                                controller.changeIsLoading(false);
                                              }
                                            },
                                            child: ButtonWidget(StringConstant.update_profile),
                                          ),
                                          SizedBox(
                                            height: 4.h,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Future<UserModel> _getData() async {
    UserModel user = await API.getLogin(false);
    controller.updateImageUrl(user.avatar);
    nameController.text = user.name;
    return user;
  }

  showCameraDialog(BuildContext context) async {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
              child: Text(
                'Take a photo',
                style: TextStyle(fontSize: 12.sp, fontFamily: 'Poppins'),
              ),
              onPressed: () async {
                try {
                  Navigator.pop(context);
                  var source = ImageSource.camera;
                  XFile image = await imagePicker.pickImage(source: source, imageQuality: 100, preferredCameraDevice: CameraDevice.front);
                  controller.updateImageFile(File(image.path));
                  controller.changeIsPhotoSelect(true);
                  uploadImage();
                } on PlatformException catch (error) {
                  if (error.code == "camera_access_denied") {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) => CupertinoAlertDialog(
                              title: Text(
                                'Camera Permission',
                                style: TextStyle(fontSize: 14.sp, fontFamily: 'Poppins'),
                              ),
                              content: Text(
                                'This app needs camera access to take pictures for upload user profile photo',
                                style: TextStyle(fontSize: 12.sp, fontFamily: 'Poppins'),
                              ),
                              actions: <Widget>[
                                CupertinoDialogAction(
                                  child: Text(
                                    'Deny',
                                    style: TextStyle(fontSize: 12.sp, fontFamily: 'Poppins'),
                                  ),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                                CupertinoDialogAction(
                                  child: Text(
                                    'Settings',
                                    style: TextStyle(fontSize: 12.sp, fontFamily: 'Poppins'),
                                  ),
                                  onPressed: () async {
                                    Navigator.pop(context);
                                    try {
                                      openAppSettings();
                                    } catch (err) {
                                      print("err");
                                      print(err);
                                    }
                                  },
                                ),
                              ],
                            ));
                  }
                } catch (error) {
                  print("error");
                  print(error);
                }
              }),
          CupertinoActionSheetAction(
              child: Text(
                'Choose from library',
                style: TextStyle(fontSize: 12.sp, fontFamily: 'Poppins'),
              ),
              onPressed: () async {
                try {
                  Navigator.pop(context);
                  var source = ImageSource.gallery;
                  XFile image = await imagePicker.pickImage(source: source, imageQuality: 100, preferredCameraDevice: CameraDevice.front);
                  controller.updateImageFile(File(image.path));
                  controller.changeIsPhotoSelect(true);
                  uploadImage();
                } on PlatformException catch (error) {
                  print(error);
                  if (error.code == "photo_access_denied") {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) => CupertinoAlertDialog(
                              title: Text(
                                'PhotoLibrary Permission',
                                style: TextStyle(fontSize: 14.sp, fontFamily: 'Poppins'),
                              ),
                              content: Text(
                                'This app needs photo library access to choose pictures for upload user profile photo',
                                style: TextStyle(fontSize: 12.sp, fontFamily: 'Poppins'),
                              ),
                              actions: <Widget>[
                                CupertinoDialogAction(
                                  child: Text(
                                    'Deny',
                                    style: TextStyle(fontSize: 12.sp, fontFamily: 'Poppins'),
                                  ),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                                CupertinoDialogAction(
                                  child: Text(
                                    'Settings',
                                    style: TextStyle(fontSize: 12.sp, fontFamily: 'Poppins'),
                                  ),
                                  onPressed: () async {
                                    Navigator.pop(context);
                                    try {
                                      openAppSettings();
                                    } catch (err) {
                                      print("err");
                                      print(err);
                                    }
                                  },
                                ),
                              ],
                            ));
                  }
                } catch (error) {}
              }),
        ],
        cancelButton: CupertinoActionSheetAction(
            child: Text(
              'Cancel',
              style: TextStyle(fontSize: 12.sp, fontFamily: 'Poppins'),
            ),
            onPressed: () {
              Navigator.pop(context);
            }),
      ),
    );
  }

  uploadImage() async {
    controller.changeIsLoading(true);
    String b_name = "fast-socialbook";
    String f_name = basename((controller.image.value as File).path);
    String c_type = "image/*";
    List<JsonValueModel> params = [];
    params.add(JsonValueModel("bucket", b_name));
    params.add(JsonValueModel("file_name", f_name));
    params.add(JsonValueModel("content_type", c_type));
    params.sort();
    final url = Uri.parse('https://socialbook.io/api/file/presigned_url?bucket=$b_name&file_name=$f_name&content_type=$c_type&s=${sToken(params)}');
    final response = await get(url);
    final Map parsed = json.decode(response.body.toString());
    try {
      var res = await put(Uri.parse(parsed['data']), body: (controller.image.value as File).readAsBytesSync());
      controller.changeIsLoading(false);
      print(res.body);
      print(res.statusCode);
      if (res.statusCode == 200) {
        var imageUrl = "https://fast-socialbook.s3.us-west-2.amazonaws.com/$f_name";
        controller.updateImageUrl(imageUrl);
      }
    } catch (e) {
      controller.changeIsLoading(false);
      throw ('Error while uploading image');
    }
  }
}
