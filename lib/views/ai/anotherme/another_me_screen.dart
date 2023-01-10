import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Common/photo_introduction_config.dart';
import 'package:cartoonizer/Controller/upload_image_controller.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/cacheImage/cached_network_image_utils.dart';
import 'package:cartoonizer/Widgets/outline_widget.dart';
import 'package:cartoonizer/Widgets/progress/circle_progress_bar.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/views/ai/anotherme/another_me_controller.dart';
import 'package:cartoonizer/views/transfer/pick_photo_screen.dart';
import 'package:image_picker/image_picker.dart';

import 'am_opt_container.dart';

class AnotherMeScreen extends StatefulWidget {
  const AnotherMeScreen({Key? key}) : super(key: key);

  @override
  State<AnotherMeScreen> createState() => _AnotherMeScreenState();
}

class _AnotherMeScreenState extends AppState<AnotherMeScreen> {
  late double sourceImageSize;
  late double transImageSize;
  AnotherMeController controller = Get.put(AnotherMeController());
  UploadImageController uploadImageController = Get.put(UploadImageController());
  ItemScrollController scrollController = ItemScrollController();

  @override
  void initState() {
    super.initState();
    sourceImageSize = ScreenUtil.screenSize.width;
    transImageSize = ScreenUtil.screenSize.width / 5;
    delay(() {
      controller.initialConfig = anotherMeInitialConfig(context);
    });
  }

  @override
  void dispose() {
    super.dispose();
    Get.delete<AnotherMeController>();
    Get.delete<UploadImageController>();
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.BackgroundColor,
      appBar: AppNavigationBar(
        backgroundColor: ColorConstant.BackgroundColor,
        middle: TitleTextWidget(
          S.of(context).meTaverse,
          ColorConstant.White,
          FontWeight.w500,
          $(18),
        ),
        trailing: GetBuilder<AnotherMeController>(
          init: controller,
          builder: (controller) => Image.asset(
            Images.ic_share,
            width: $(24),
          ).visibility(visible: controller.hasTransRecord()),
        ),
      ),
      body: GetBuilder<AnotherMeController>(
        init: controller,
        builder: (controller) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                children: [
                  AppCircleProgressBar(
                    size: $(50),
                    ringWidth: 4,
                    backgroundColor: ColorConstant.White,
                    loadingColors: [
                      ColorConstant.colorBlue,
                      ColorConstant.colorBlue2,
                      ColorConstant.colorBlue3,
                    ],
                    progress: 0.5,
                  ),
                  Text(
                    '50',
                    style: TextStyle(fontFamily: 'Poppins', color: ColorConstant.White, fontWeight: FontWeight.w500, fontSize: $(18)),
                  ).intoContainer(
                    width: $(50),
                    height: $(50),
                    alignment: Alignment.center,
                  ),
                ],
              ),
              Expanded(
                child: buildImageContainer(context, controller),
              ),
              buildOptContainer(context, controller).intoContainer(margin: EdgeInsets.symmetric(horizontal: $(25))),
              buildTransRecord(context, controller),
            ],
          );
        },
      ),
    );
  }

  Widget buildImageContainer(BuildContext context, AnotherMeController controller) {
    return controller.hasChoosePhoto()
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              controller.transKeyList.isEmpty
                  ? Image.file(
                      controller.sourcePhoto!,
                      width: sourceImageSize,
                      height: sourceImageSize,
                    )
                  : CachedNetworkImageUtils.custom(
                      context: context,
                      imageUrl: controller.transKeyList[controller.recordIndex],
                      useOld: true,
                      cacheManager: controller.transManager,
                      width: sourceImageSize,
                      height: sourceImageSize,
                    ),
            ],
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              controller.initialConfig.containsKey('image')
                  ? Image.asset(
                      controller.initialConfig['image'],
                      width: sourceImageSize,
                      height: sourceImageSize,
                    )
                  : Container(),
              SizedBox(height: $(80)),
              controller.initialConfig.containsKey('text')
                  ? Text(
                      controller.initialConfig['text'],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        height: 1,
                        fontSize: 21,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Color(0xffc4400c),
                            blurRadius: 6,
                            offset: Offset(4, 0),
                          ),
                          Shadow(
                            color: Color(0xffc4400c),
                            blurRadius: 6,
                            offset: Offset(-4, 0),
                          ),
                        ],
                      ),
                    ).intoContainer(
                      alignment: Alignment.center,
                    )
                  : Container()
            ],
          );
  }

  Widget buildOptContainer(BuildContext context, AnotherMeController controller) {
    return controller.hasTransRecord()
        ? Column(children: [
            AMOptContainer(
              onChoosePhotoTap: () {
                choosePhoto(context, controller);
              },
              onDownloadTap: () {},
              onShareDiscoveryTap: () {},
            ),
            Text(
              S.of(context).generate_again,
              style: TextStyle(fontFamily: 'Poppins', color: ColorConstant.White, fontSize: $(16), fontWeight: FontWeight.w600),
            )
                .intoContainer(
                    width: double.maxFinite,
                    padding: EdgeInsets.symmetric(vertical: $(10)),
                    margin: EdgeInsets.only(bottom: $(20), top: $(50), left: $(25), right: $(25)),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: ColorConstant.DiscoveryBtn,
                      borderRadius: BorderRadius.circular($(8)),
                    ))
                .intoGestureDetector(onTap: () {
              startGenerate(controller);
            }),
          ])
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(Images.ic_camera, width: $(24)),
              SizedBox(width: $(8)),
              Text(
                S.of(context).choose_photo,
                style: TextStyle(fontFamily: 'Poppins', color: ColorConstant.White, fontSize: $(16), fontWeight: FontWeight.w600),
              ),
            ],
          )
            .intoContainer(
                width: double.maxFinite,
                padding: EdgeInsets.symmetric(vertical: $(10)),
                margin: EdgeInsets.only(bottom: $(50), top: $(80)),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: ColorConstant.DiscoveryBtn,
                  borderRadius: BorderRadius.circular($(8)),
                ))
            .intoGestureDetector(onTap: () {
            choosePhoto(context, controller);
          });
  }

  choosePhoto(BuildContext context, AnotherMeController controller) async {
    PickPhotoScreen.push(context, selectedFile: controller.sourcePhoto, controller: uploadImageController, onPickFromSystem: (takePhoto) async {
      await showLoading();
      bool result = await controller.takePhoto(takePhoto ? ImageSource.camera : ImageSource.gallery, uploadImageController);
      await hideLoading();
      return result;
    }, onPickFromRecent: (record) async {
      await showLoading();
      bool result = await controller.pickFromRecent(record, uploadImageController);
      await hideLoading();
      return result;
    }, onPickFromAiSource: (file) async {
      await showLoading();
      bool result = await controller.pickFromAiSource(file, uploadImageController);
      await hideLoading();
      return result;
    }, floatWidget: null)
        .then((value) {
      if (value ?? false) {
        startGenerate(controller);
      }
    });
  }

  Future<bool> startGenerate(AnotherMeController controller) async {
    await showLoading();
    var value = await controller.startTransfer(uploadImageController.imageUrl.value);
    if (value) {
      if (controller.transKeyList.length > 4) {
        scrollController.scrollTo(
          index: controller.transKeyList.length - 5,
          duration: Duration(milliseconds: 300),
          alignment: -0.085,
        );
      }
    }
    await hideLoading();
    return value;
  }

  Widget buildTransRecord(BuildContext context, AnotherMeController controller) {
    if (!controller.hasTransRecord()) {
      return SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TitleTextWidget(
          S.of(context).generate_record,
          ColorConstant.White,
          FontWeight.w500,
          $(15),
          align: TextAlign.start,
        ).intoContainer(margin: EdgeInsets.symmetric(horizontal: $(15))),
        SizedBox(height: $(12)),
        ScrollablePositionedList.separated(
          padding: EdgeInsets.symmetric(horizontal: $(15)),
          itemScrollController: scrollController,
          scrollDirection: Axis.horizontal,
          itemCount: controller.transKeyList.length,
          itemBuilder: (context, index) {
            var e = controller.transKeyList[index];
            var checked = controller.recordIndex == index;
            Widget icon = OutlineWidget(
              radius: $(2),
              strokeWidth: 2,
              gradient: LinearGradient(
                colors: [checked ? Color(0xffE31ECD) : Colors.transparent, checked ? Color(0xff243CFF) : Colors.transparent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              child: ClipRRect(
                child: CachedNetworkImageUtils.custom(
                  context: context,
                  imageUrl: e,
                  useOld: true,
                  width: transImageSize - $(4),
                  height: transImageSize - $(4),
                  cacheManager: controller.transManager,
                ),
                borderRadius: BorderRadius.circular($(1)),
              ).intoContainer(
                padding: EdgeInsets.all($(2)),
                width: transImageSize,
                height: transImageSize,
              ),
            );
            return icon.intoGestureDetector(onTap: () {
              controller.onSelectRecord(index);
            });
          },
          separatorBuilder: (context, index) => Container(width: 4),
        ).intoContainer(height: transImageSize),
      ],
    ).intoContainer(
      margin: EdgeInsets.only(
        top: $(25),
        bottom: ScreenUtil.getBottomPadding(context, padding: $(30)),
      ),
    );
  }
}
