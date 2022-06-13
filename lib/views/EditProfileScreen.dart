import 'dart:convert';
import 'dart:io';

import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/Controller/EditProfileScreenController.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

import '../common/Extension.dart';
import '../models/UserModel.dart';
import 'package:cartoonizer/api.dart';
import 'package:cartoonizer/common/utils.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final EditProfileScreenController controller = EditProfileScreenController();
  late ImagePicker imagePicker;
  final nameController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    logEvent(Events.edit_profile_page_loading);

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
                        margin: EdgeConstants.TopBarEdgeInsets,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () => {Navigator.pop(context)},
                              child: Image.asset(
                                ImagesConstant.ic_back,
                                height: 30,
                                width: 30,
                              ),
                            ),
                            TitleTextWidget(StringConstant.edit_profile, ColorConstant.BtnTextColor, FontWeight.w600, FontSizeConstants.topBarTitle),
                            SizedBox(
                              height: 30,
                              width: 30,
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
                                          SimpleTextInputWidget(StringConstant.name_hint, ColorConstant.TextBlack, FontWeight.w400, 12.sp, TextInputAction.done,
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
                                                var name = nameController.text.toString();
                                                var avatar = controller.imageUrl.value;

                                                var body = {
                                                  'name': name,
                                                  'avatar': avatar,
                                                };

                                                final updateProfileResponse = await API.post("/api/user/update", body: body);

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
    UserModel user = await API.getLogin();
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
                  XFile? image = await imagePicker.pickImage(source: source, imageQuality: 100, preferredCameraDevice: CameraDevice.front);
                  if(image == null) {
                    return;
                  }
                  controller.updateImageFile(File(image.path));
                  controller.changeIsPhotoSelect(true);
                  uploadImage();
                } on PlatformException catch (error) {
                  if (error.code == "camera_access_denied") {
                    showCameraPermissionDialog(context);
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
                  XFile? image = await imagePicker.pickImage(source: source, imageQuality: 100, preferredCameraDevice: CameraDevice.front);
                  if(image == null) {
                    return;
                  }
                  controller.updateImageFile(File(image.path));
                  controller.changeIsPhotoSelect(true);
                  uploadImage();
                } on PlatformException catch (error) {
                  print(error);
                  if (error.code == "photo_access_denied") {
                    showPhotoLibraryPermissionDialog(context);
                  }
                } catch (error) {
                  print(error);
                }
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
    String f_name = basename((controller.image.value as File).path);

    final params = {
      'bucket': "fast-socialbook",
      'file_name': f_name,
      'content_type': "image/*",
    };

    final response = await API.get("https://socialbook.io/api/file/presigned_url", params: params);
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
