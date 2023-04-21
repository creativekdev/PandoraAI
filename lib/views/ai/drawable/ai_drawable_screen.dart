import 'dart:io';

import 'package:cartoonizer/Common/Extension.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/image/sync_image_provider.dart';
import 'package:cartoonizer/Widgets/router/routers.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/views/ai/drawable/ai_drawable_result_screen.dart';
import 'package:cartoonizer/views/ai/drawable/widget/drawable.dart';
import 'package:cartoonizer/views/ai/drawable/widget/drawable_opt.dart';
import 'package:cartoonizer/views/input/input_screen.dart';
import 'package:common_utils/common_utils.dart';

class AiDrawableScreen extends StatefulWidget {
  const AiDrawableScreen({Key? key}) : super(key: key);

  @override
  State<AiDrawableScreen> createState() => _AiDrawableScreenState();
}

class _AiDrawableScreenState extends AppState<AiDrawableScreen> {
  double width = 0;
  double height = 0;
  DrawableController drawableController = DrawableController();
  double descriptionHeight = 0;
  CacheManager cacheManager = AppDelegate.instance.getManager();

  @override
  void initState() {
    super.initState();
    drawableController.onUpdated = () {
      setState(() {});
    };
    delay(() {
      descriptionHeight = $(96) + ScreenUtil.getBottomPadding(context);
      width = ScreenUtil.screenSize.width;
      height = ScreenUtil.screenSize.height - kNavBarPersistentHeight - ScreenUtil.getStatusBarHeight() - descriptionHeight;
      setState(() {});
    });
  }

  @override
  void didUpdateWidget(covariant AiDrawableScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    descriptionHeight = $(96) + ScreenUtil.getBottomPadding(context);
    width = ScreenUtil.screenSize.width;
    height = ScreenUtil.screenSize.height - kNavBarPersistentHeight - ScreenUtil.getStatusBarHeight() - descriptionHeight;
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
              color: Colors.black,
              height: $(24),
              width: $(24),
            ),
            Text(
              'AI-Draw',
              style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500, fontSize: $(18), color: Colors.black),
            ),
          ],
        ).intoGestureDetector(onTap: () {
          Navigator.of(context).pop();
        }),
        showBackItem: false,
        middle: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              Images.ic_rollback,
              color: drawableController.canRollback() ? Colors.black : Colors.grey.shade400,
              width: $(22),
            ).intoContainer(padding: EdgeInsets.all($(8)), color: Colors.transparent).intoGestureDetector(onTap: () {
              drawableController.rollback();
            }).ignore(ignoring: !drawableController.canRollback()),
            Image.asset(
              Images.ic_forward,
              color: drawableController.canForward() ? Colors.black : Colors.grey.shade400,
              width: $(22),
            ).intoContainer(padding: EdgeInsets.all($(8)), color: Colors.transparent).intoGestureDetector(onTap: () {
              drawableController.forward();
            }).ignore(ignoring: !drawableController.canForward()),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              Images.ic_recent_delete,
              color: Colors.black,
              width: $(22),
            ).intoContainer(padding: EdgeInsets.all($(8)), color: Colors.transparent).intoGestureDetector(onTap: () {
              drawableController.reset();
            }),
            SizedBox(width: $(10)),
            Text(
              S.of(context).done,
              style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500, fontSize: $(17), color: Colors.black),
            ).intoContainer(padding: EdgeInsets.only(left: $(6), top: $(8), bottom: $(8)), color: Colors.transparent).intoGestureDetector(onTap: () {
              if (drawableController.isEmpty()) {
                return;
              }
              showLoading().whenComplete(() {
                drawableController.getImage().then((value) async {
                  var uploadPath = cacheManager.storageOperator.imageDir.path + 'ai-draw-upload.png';
                  var uploadFile = File(uploadPath);
                  if (uploadFile.existsSync()) {
                    await uploadFile.delete();
                  }
                  await uploadFile.writeAsBytes(value![1].toList(), flush: true);
                  var imageInfo = await SyncMemoryImage(list: value[0]).getImage();
                  hideLoading().whenComplete(() {
                    Navigator.of(context).push(
                      FadeRouter(
                        child: AiDrawableResultScreen(
                          drawableController: drawableController,
                          filePath: uploadPath,
                          localImage: value[0],
                          scale: imageInfo.image.width / imageInfo.image.height,
                          photoType: 'ai_draw',
                        ),
                        opaque: false,
                      ),
                    );
                  });
                });
              });
            }),
          ],
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            child: Drawable(controller: drawableController, size: Size(width, height)),
            bottom: descriptionHeight,
            left: 0,
            right: 0,
            top: 0,
          ),
          Positioned(
            child: Text(
              TextUtil.isEmpty(drawableController.textEditingController.text) ? S.of(context).ai_draw_hint : drawableController.textEditingController.text,
              style: TextStyle(
                color: Color(0xff999999),
                fontWeight: FontWeight.w400,
                fontFamily: 'Poppins',
                fontSize: $(15),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
                .intoContainer(
                    padding: EdgeInsets.symmetric(horizontal: $(16), vertical: $(10)),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular($(8)), color: ColorConstant.aiDrawGrey),
                    margin: EdgeInsets.only(bottom: $(12)))
                .intoGestureDetector(onTap: () {
              Navigator.push(
                  context,
                  PageRouteBuilder(
                    opaque: false,
                    pageBuilder: (context, animation, secondaryAnimation) => InputScreen(
                      hasSend: false,
                      uniqueId: "ai_draw",
                      hint: S.of(context).ai_draw_hint,
                      oldString: drawableController.textEditingController.text,
                      callback: (text) async {
                        drawableController.textEditingController.text = text;
                        return true;
                      },
                    ),
                  ));
            }),
            left: $(15),
            right: $(15),
            top: height - $(10),
          ),
          DrawableOpt(controller: drawableController),
        ],
      ),
      resizeToAvoidBottomInset: false,
    );
    return WillPopScope(
        child: content,
        onWillPop: () async {
          return false;
        });
  }
}
