import 'dart:io';
import 'dart:math';

import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/dialog/dialog_widget.dart';
import 'package:cartoonizer/Widgets/image/sync_image_provider.dart';
import 'package:cartoonizer/Widgets/router/routers.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/api/app_api.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/models/enums/account_limit_type.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:cartoonizer/views/ai/drawable/scribble/ai_drawable_result_screen.dart';
import 'package:cartoonizer/views/ai/drawable/scribble/widget/drawable.dart';
import 'package:cartoonizer/views/ai/drawable/scribble/widget/drawable_opt.dart';
import 'package:cartoonizer/views/input/real_time_input_screen.dart';
import 'package:common_utils/common_utils.dart';

import 'ai_prompt_view.dart';

class AiDrawableScreen extends StatefulWidget {
  DrawableRecord? record;
  String source;

  AiDrawableScreen({
    Key? key,
    this.record,
    required this.source,
  }) : super(key: key);

  @override
  State<AiDrawableScreen> createState() => _AiDrawableScreenState();
}

class _AiDrawableScreenState extends AppState<AiDrawableScreen> {
  double width = 0;
  double height = 0;
  late DrawableController drawableController;
  double descriptionHeight = 0;
  CacheManager cacheManager = AppDelegate.instance.getManager();
  GlobalKey<DrawableOptState> optKey = GlobalKey<DrawableOptState>();
  UserManager userManager = AppDelegate().getManager();

  @override
  void initState() {
    super.initState();
    drawableController = DrawableController(data: widget.record, source: widget.source);
    drawableController.background = Colors.white;
    drawableController.activePens.forEach((element) {
      element.buildPaint(drawableController);
      element.buildPath();
      element.buildImage();
    });
    drawableController.checkmatePens.forEach((element) {
      element.buildPaint(drawableController);
      element.buildPath();
      element.buildImage();
    });
    drawableController.onStartDraw = () {
      optKey.currentState?.dismiss();
    };
    delay(() {
      descriptionHeight = $(96) + ScreenUtil.getBottomPadding(context);
      width = ScreenUtil.screenSize.width - $(30);
      height = ScreenUtil.screenSize.height - kNavBarPersistentHeight - ScreenUtil.getStatusBarHeight() - descriptionHeight;
      setState(() {});
      if (widget.record != null) {
        delay(() {
          toResultWithoutCheck();
        }, milliseconds: 200);
      }
    });
  }

  toResult() async {
    showLoading().whenComplete(() async {
      var aiDrawLimitEntity = await AppApi().getAiDrawLimit();
      if (aiDrawLimitEntity == null) {
        hideLoading();
      } else {
        if (aiDrawLimitEntity.usedCount >= aiDrawLimitEntity.dailyLimit) {
          var type;
          if (AppDelegate.instance.getManager<UserManager>().isNeedLogin) {
            type = AccountLimitType.guest;
          } else if (isVip()) {
            type = AccountLimitType.vip;
          } else {
            type = AccountLimitType.normal;
          }
          hideLoading().whenComplete(() {
            showLimitDialog(context, type: type, function: 'ai_draw', source: 'ai_draw_result_screen');
          });
        } else {
          toResultWithoutCheck();
        }
      }
    });
  }

  toResultWithoutCheck() {
    drawableController.getImage(screenShotScale: 3.0).then((value) async {
      var key = EncryptUtil.encodeMd5(DrawableRecord(activePens: drawableController.activePens).toString());
      var uploadPath = cacheManager.storageOperator.recordAiDrawDir.path + key + '.jpg';
      var uploadFile = File(uploadPath);
      if (uploadFile.existsSync()) {
        await uploadFile.delete();
      }
      await uploadFile.writeAsBytes(value!.toList(), flush: true);
      if (drawableController.activePens.isNotEmpty && drawableController.activePens.last.drawMode == DrawMode.camera) {
        drawableController.activePens.last.filePath = uploadPath;
      }
      var imageInfo = await SyncMemoryImage(list: value).getImage();
      String photoType;
      if (drawableController.activePens.last.drawMode == DrawMode.camera) {
        photoType = 'ai_draw_${drawableController.activePens.last.source}';
      } else {
        photoType = 'ai_draw';
      }
      Navigator.of(context).push(
        FadeRouter(
          settings: RouteSettings(name: '/AiDrawableResultScreen'),
          child: AiDrawableResultScreen(
            drawableController: drawableController,
            filePath: uploadPath,
            scale: imageInfo.image.width / imageInfo.image.height,
            photoType: photoType,
            source: widget.source,
          ),
          opaque: false,
        ),
      );
      hideLoading();
    });
  }

  @override
  Widget buildWidget(BuildContext context) {
    var content = Scaffold(
      backgroundColor: Colors.white,
      appBar: AppNavigationBar(
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              Images.ic_back,
              color: ColorConstant.aiDrawBlue,
              height: $(24),
              width: $(24),
            ),
            Text(
              'AI-Scribble',
              style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500, fontSize: $(17), color: ColorConstant.aiDrawBlue),
            ),
          ],
        ).intoGestureDetector(onTap: () {
          if (drawableController.isEmpty()) {
            Navigator.of(context).pop();
          } else {
            _willPopCallback(context);
          }
        }),
        showBackItem: false,
        middle: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(
              () => Image.asset(
                Images.ic_rollback,
                color: drawableController.canRollback.value ? ColorConstant.aiDrawBlue : Colors.grey.shade400,
                width: $(22),
              ).intoContainer(padding: EdgeInsets.all($(8)), color: Colors.transparent).intoGestureDetector(onTap: () {
                drawableController.rollback();
              }).ignore(ignoring: !drawableController.canRollback.value),
            ),
            Obx(
              () => Image.asset(
                Images.ic_forward,
                color: drawableController.canForward.value ? ColorConstant.aiDrawBlue : Colors.grey.shade400,
                width: $(22),
              ).intoContainer(padding: EdgeInsets.all($(8)), color: Colors.transparent).intoGestureDetector(onTap: () {
                drawableController.forward();
              }).ignore(ignoring: !drawableController.canForward.value),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(() => Image.asset(
                  Images.ic_ai_draw_delete,
                  color: ColorConstant.aiDrawBlue,
                  width: $(20),
                ).intoContainer(padding: EdgeInsets.all($(8)), color: Colors.transparent).intoGestureDetector(onTap: () {
                  showResetDialog().then((value) {
                    if (value ?? false) {
                      drawableController.reset();
                    }
                  });
                }).visibility(visible: !drawableController.isEmpty.value)),
            Obx(
              () => Text(
                S.of(context).done,
                style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500, fontSize: $(17), color: ColorConstant.aiDrawBlue),
              ).intoContainer(padding: EdgeInsets.only(left: $(6), top: $(8), bottom: $(8)), color: Colors.transparent).intoGestureDetector(onTap: () {
                toResult();
              }).visibility(visible: !drawableController.isEmpty.value),
            )
          ],
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            child: Drawable(controller: drawableController, size: Size(width, min(height, $(440))))
                .intoContainer(width: width, height: min(height, $(440)), decoration: BoxDecoration(border: Border.all(color: Color(0xffcacacb), width: 1)))
                .intoCenter(),
            bottom: descriptionHeight,
            left: 0,
            right: 0,
            top: 0,
          ),
          Positioned(
            child: Obx(() => Text(
                      TextUtil.isEmpty(drawableController.text.value) ? S.of(context).ai_draw_hint : drawableController.text.value,
                      style: TextStyle(
                        color: Color(0xff999999),
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Poppins',
                        fontSize: $(15),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ))
                .intoContainer(
                    padding: EdgeInsets.symmetric(horizontal: $(16), vertical: $(10)),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular($(8)), color: ColorConstant.aiDrawGrey),
                    margin: EdgeInsets.only(bottom: $(12)))
                .intoGestureDetector(onTap: () {
              Navigator.push(
                  context,
                  PageRouteBuilder(
                    opaque: false,
                    pageBuilder: (context, animation, secondaryAnimation) => RealTimeInputScreen(
                      hint: S.of(context).ai_draw_hint,
                      oldString: drawableController.text.value,
                      onChange: (text) {
                        drawableController.text.value = text;
                      },
                    ),
                  ));
            }),
            left: $(15),
            right: $(15),
            top: height - $(10),
          ),
          Positioned(
            child: AiPromptView(),
            left: $(15),
            right: $(15),
            top: height - $(50),
          ),
          DrawableOpt(
            key: optKey,
            controller: drawableController,
          ),
        ],
      ),
      resizeToAvoidBottomInset: false,
    );
    return WillPopScope(
        child: content,
        onWillPop: () async {
          if (drawableController.isEmpty.value) {
            return true;
          }
          _willPopCallback(context);
          return false;
        });
  }

  _willPopCallback(BuildContext context) async {
    showDialog<bool>(
      context: context,
      builder: (BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: $(20)),
          TitleTextWidget(S.of(context).exit_msg, Colors.black, FontWeight.w600, $(17)),
          SizedBox(height: $(15)),
          TitleTextWidget(S.of(context).exit_msg1, Colors.black, FontWeight.w400, $(13), maxLines: 2).intoContainer(padding: EdgeInsets.symmetric(horizontal: $(25))),
          SizedBox(height: $(15)),
          Divider(height: 1, color: ColorConstant.LightLineColor),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: TitleTextWidget(
                  S.of(context).txtContinue,
                  ColorConstant.aiDrawBlue,
                  FontWeight.w400,
                  $(17),
                ).intoContainer(padding: EdgeInsets.symmetric(vertical: $(10)), color: Colors.transparent).intoGestureDetector(onTap: () {
                  Navigator.pop(context, true);
                }),
              ),
              Container(
                height: $(46),
                width: 0.5,
                color: ColorConstant.LightLineColor,
              ),
              Expanded(
                child: TitleTextWidget(
                  S.of(context).cancel,
                  ColorConstant.aiDrawBlue,
                  FontWeight.w500,
                  $(17),
                ).intoContainer(padding: EdgeInsets.symmetric(vertical: $(10)), color: Colors.transparent).intoGestureDetector(onTap: () {
                  Navigator.pop(context);
                }),
              ),
            ],
          ).intoContainer(padding: EdgeInsets.symmetric(horizontal: $(15))),
        ],
      ).customDialogStyle(color: Colors.white),
    ).then((value) {
      if (value ?? false) {
        Navigator.pop(context);
      }
    });
  }

  Future<bool?> showResetDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: $(20)),
          TitleTextWidget(S.of(context).ai_draw_reset_tips, Colors.black, FontWeight.w600, $(17)),
          SizedBox(height: $(15)),
          TitleTextWidget(S.of(context).ai_draw_reset_tips_desc, Colors.black, FontWeight.w400, $(13), maxLines: 10)
              .intoContainer(padding: EdgeInsets.symmetric(horizontal: $(25))),
          SizedBox(height: $(15)),
          Divider(height: 1, color: ColorConstant.LightLineColor),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: TitleTextWidget(
                  S.of(context).ai_draw_clear_btn,
                  ColorConstant.aiDrawBlue,
                  FontWeight.w400,
                  $(17),
                ).intoContainer(padding: EdgeInsets.symmetric(vertical: $(10)), color: Colors.transparent).intoGestureDetector(onTap: () {
                  Navigator.pop(context, true);
                }),
              ),
              Container(
                height: $(46),
                width: 0.5,
                color: ColorConstant.LightLineColor,
              ),
              Expanded(
                child: TitleTextWidget(
                  S.of(context).cancel,
                  ColorConstant.aiDrawBlue,
                  FontWeight.w500,
                  $(17),
                ).intoContainer(padding: EdgeInsets.symmetric(vertical: $(10)), color: Colors.transparent).intoGestureDetector(onTap: () {
                  Navigator.pop(context);
                }),
              ),
            ],
          ).intoContainer(padding: EdgeInsets.symmetric(horizontal: $(15))),
        ],
      ).customDialogStyle(color: Colors.white),
    );
  }
}
