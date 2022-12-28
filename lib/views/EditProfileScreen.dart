import 'dart:convert';
import 'dart:io';

import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Controller/EditProfileScreenController.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/cacheImage/cached_network_image_utils.dart';
import 'package:cartoonizer/api/api.dart';
import 'package:cartoonizer/api/uploader.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/thirdpart/thirdpart_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/models/social_user_info.dart';
import 'package:common_utils/common_utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

import '../common/Extension.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final EditProfileScreenController controller = EditProfileScreenController();
  late ImagePicker imagePicker;
  final nameController = TextEditingController();

  UserManager userManager = AppDelegate.instance.getManager();
  ThirdpartManager thirdpartManager = AppDelegate.instance.getManager();

  @override
  void initState() {
    super.initState();
    logEvent(Events.edit_profile_page_loading);
    thirdpartManager.adsHolder.ignore = true;
    imagePicker = new ImagePicker();
  }

  @override
  void dispose() {
    nameController.dispose();
    thirdpartManager.adsHolder.ignore = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.BackgroundColor,
      appBar: AppNavigationBar(
        blurAble: false,
        backgroundColor: Colors.transparent,
        middle: TitleTextWidget(
          S.of(context).edit_profile,
          ColorConstant.BtnTextColor,
          FontWeight.w600,
          FontSizeConstants.topBarTitle,
        ),
      ),
      body: FutureBuilder(
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
                                                    : CachedNetworkImageUtils.custom(
                                                        context: context,
                                                        imageUrl: (snapshot.hasData) ? (snapshot.data as SocialUserInfo).getShownAvatar() : "",
                                                        width: 40.w,
                                                        height: 40.w,
                                                        fit: BoxFit.fill,
                                                        errorWidget: (context, url, error) {
                                                          return Image.asset(
                                                            Images.ic_demo1,
                                                            fit: BoxFit.fill,
                                                            width: 40.w,
                                                            height: 40.w,
                                                          );
                                                        }),
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
                                  TitleTextWidget(
                                      (snapshot.hasData) ? (snapshot.data as SocialUserInfo).getShownEmail() : "", ColorConstant.LightTextColor, FontWeight.w400, 14.sp),
                                  SizedBox(
                                    height: 2.h,
                                  ),
                                  SimpleTextInputWidget(S.of(context).name_hint, ColorConstant.TextBlack, FontWeight.w400, 12.sp, TextInputAction.done, TextInputType.emailAddress,
                                      false, nameController),
                                  SizedBox(
                                    height: 4.h,
                                  ),
                                  GestureDetector(
                                    onTap: () async {
                                      if (nameController.text.trim().isEmpty) {
                                        CommonExtension().showToast(S.of(context).name_validation);
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

                                        if (updateProfileResponse.statusCode == 200) {
                                          CommonExtension().showToast("Profile update successfully!!");
                                          AppDelegate.instance.getManager<UserManager>().refreshUser();
                                          Navigator.pop(context, false);
                                        } else {
                                          CommonExtension().showToast("Oops something went wrong!!");
                                        }

                                        controller.changeIsLoading(false);
                                      }
                                    },
                                    child: ButtonWidget(S.of(context).update_profile),
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
            );
          }
        },
      ),
    );
  }

  Future<SocialUserInfo> _getData() async {
    var user = userManager.user!;
    controller.updateImageUrl(user.getShownAvatar());
    nameController.text = user.getShownName();
    return user;
  }

  showCameraDialog(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TitleTextWidget('Select from album', ColorConstant.White, FontWeight.normal, $(17))
                  .intoContainer(
                width: double.maxFinite,
                padding: EdgeInsets.symmetric(vertical: $(10)),
                color: Colors.transparent,
              )
                  .intoGestureDetector(onTap: () async {
                try {
                  Navigator.pop(context);
                  var source = ImageSource.gallery;
                  XFile? image = await imagePicker.pickImage(source: source, imageQuality: 100, preferredCameraDevice: CameraDevice.front);
                  if (image == null) {
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
              Divider(height: 0.5, color: ColorConstant.EffectGrey).intoContainer(margin: EdgeInsets.symmetric(horizontal: $(25))),
              TitleTextWidget('Take a selfie', ColorConstant.White, FontWeight.normal, $(17))
                  .intoContainer(
                width: double.maxFinite,
                padding: EdgeInsets.symmetric(vertical: $(10)),
                color: Colors.transparent,
              )
                  .intoGestureDetector(onTap: () async {
                try {
                  Navigator.pop(context);
                  var source = ImageSource.camera;
                  XFile? image = await imagePicker.pickImage(source: source, imageQuality: 100, preferredCameraDevice: CameraDevice.front);
                  if (image == null) {
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
              Container(height: $(10), width: double.maxFinite, color: ColorConstant.BackgroundColor),
              TitleTextWidget(S.of(context).cancel, ColorConstant.White, FontWeight.normal, $(17))
                  .intoContainer(
                width: double.maxFinite,
                padding: EdgeInsets.only(top: $(10), bottom: $(10) + MediaQuery.of(context).padding.bottom),
                color: Colors.transparent,
              )
                  .intoGestureDetector(onTap: () {
                Navigator.of(context).pop();
              }),
            ],
          ).intoContainer(
              padding: EdgeInsets.only(top: $(19), bottom: $(10)),
              decoration: BoxDecoration(
                  color: ColorConstant.EffectFunctionGrey,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular($(24)),
                    topRight: Radius.circular($(24)),
                  )));
        },
        backgroundColor: Colors.transparent);
  }

  uploadImage() async {
    controller.changeIsLoading(true);
    String f_name = basename((controller.image.value as File).path);
    var fileType = f_name.substring(f_name.lastIndexOf(".") + 1);
    if (TextUtil.isEmpty(fileType)) {
      fileType = '*';
    }
    String c_type = "image/${fileType}";
    final params = {
      'bucket': "fast-socialbook",
      'file_name': f_name,
      'content_type': c_type,
    };

    final response = await API.get("https://socialbook.io/api/file/presigned_url", params: params);
    final Map parsed = json.decode(response.body.toString());
    try {
      var url = parsed['data'];
      var baseEntity = await Uploader().uploadFile(url, controller.image.value as File, c_type);
      controller.changeIsLoading(false);
      if (baseEntity != null) {
        var imageUrl = url.split("?")[0];
        // var imageUrl = "https://fast-socialbook.s3.us-west-2.amazonaws.com/$f_name";
        controller.updateImageUrl(imageUrl);
      }
    } catch (e) {
      controller.changeIsLoading(false);
      throw ('Error while uploading image');
    }
  }
}
