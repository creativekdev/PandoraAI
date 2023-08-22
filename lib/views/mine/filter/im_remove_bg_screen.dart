import 'dart:io';
import 'dart:math';

import 'package:cartoonizer/Controller/upload_image_controller.dart';
import 'package:common_utils/common_utils.dart';

import '../../../Common/importFile.dart';
import '../../../Widgets/app_navigation_bar.dart';
import '../../../Widgets/dialog/dialog_widget.dart';
import '../../../api/app_api.dart';
import '../../../api/remove_bg_api.dart';
import '../../../app/app.dart';
import '../../../app/user/user_manager.dart';
import '../../../models/enums/account_limit_type.dart';
import '../../../network/dio_node.dart';
import '../../../utils/utils.dart';
import '../../ai/anotherme/another_me_controller.dart';

typedef OnGetRemoveBgImage = void Function(String removeBgUrl);

class ImRemoveBgScreen extends StatefulWidget {
  const ImRemoveBgScreen(
      {super.key,
      required this.onGetRemoveBgImage,
      required this.filePath,
      required this.imageRatio,
      this.bottomPadding = 0,
      this.switchButtonBottomToScreen = 0,
      required this.imageHeight,
      required this.imageWidth,
      required this.size});

  final String filePath;
  final OnGetRemoveBgImage onGetRemoveBgImage;
  final double imageRatio;
  final double bottomPadding;
  final double switchButtonBottomToScreen;
  final double imageHeight;
  final double imageWidth;
  final Size size;

  @override
  State<ImRemoveBgScreen> createState() => _ImRemoveBgScreenState();
}

class _ImRemoveBgScreenState extends State<ImRemoveBgScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool isRequset = true;
  bool isLoaded = false;
  bool isReverse = false;

  String? removeBgUrl;
  late double _width;
  late double _height;
  UploadImageController uploadImageController = Get.find();
  GlobalKey globalKey = GlobalKey();
  late AppApi appApi;

  @override
  void initState() {
    super.initState();
    appApi = AppApi();

    final int imgWidth = widget.imageWidth.toInt();
    final int imgHeight = widget.imageHeight.toInt();
    if ((imgWidth / widget.size.width) > (imgHeight / widget.size.height)) {
      _height = widget.size.width * imgHeight / imgWidth;
      _width = widget.size.width;
    } else {
      _width = widget.size.height * imgWidth / imgHeight;
      _height = widget.size.height;
    }

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _controller.addStatusListener((status) {
      switch (status) {
        case AnimationStatus.forward:
          if (isRequset == false && isLoaded == true) {
            _controller.stop();
            if (removeBgUrl != null) {
              widget.onGetRemoveBgImage(removeBgUrl!);
            }
            Future.delayed(Duration(milliseconds: 300), () {
              Navigator.of(context).pop(removeBgUrl != null);
            });
          }
          break;
        case AnimationStatus.reverse:
          if (isRequset == false) {
            setState(() {
              isLoaded = true;
            });
          }
          break;
        case AnimationStatus.completed:
          _controller.reverse();
          isReverse = true;
          break;
        case AnimationStatus.dismissed:
          _controller.forward();
          isReverse = false;
          break;
      }
    });
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
    delay(() => onGetRemovebgImage());
  }

  onGetRemovebgImage() async {
    var removeBgLimitEntity = await appApi.getRemoveBgLimit();
    if (removeBgLimitEntity != null) {
      AccountLimitType? type;
      if (removeBgLimitEntity.usedCount >= removeBgLimitEntity.dailyLimit) {
        if (AppDelegate.instance.getManager<UserManager>().isNeedLogin) {
          type = AccountLimitType.guest;
        } else if (isVip()) {
          type = AccountLimitType.vip;
        } else {
          type = AccountLimitType.normal;
        }
      }
      if (type != null) {
        showLimitDialog(context, type: type, function: "removeBg", source: "image_edition_screen");
        return;
      }
    }
    uploadImageController.upload(file: File(widget.filePath)).then((value) async {
      if (TextUtil.isEmpty(value)) {
        isRequset = false;
        removeBgUrl = null;
      } else {
        removeBgUrl = await RemoveBgApi(client: DioNode().build(logResponseEnable: false)).removeBgAndSave(
            originalPath: widget.filePath,
            imageUrl: value!,
            onFailed: (response) {
              uploadImageController.deleteUploadData(File(widget.filePath));
              Navigator.of(context).pop(false);
            });
        if (removeBgUrl != null) {
          isRequset = false;
        }
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    appApi.unbind();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xaa000000),
      appBar: AppNavigationBar(
          backgroundColor: Colors.transparent,
          leading: SizedBox(),
          backAction: () {
            Navigator.popUntil(context, ModalRoute.withName('/HomeScreen'));
          }),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Stack(
                // alignment: Alignment.topCenter,
                children: [
                  if (isLoaded == true) // 显示生成的图片
                    Image.file(
                      File(removeBgUrl!),
                      // width: width,
                      // height: height,
                      fit: BoxFit.contain,
                    ),
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      double offsetY = _height * _animation.value;
                      return Stack(
                        children: [
                          ClipPath(
                            //  矩形裁剪
                            clipper: ReactClipper(isLoaded ? offsetY : _height),
                            child: Image.file(
                              key: globalKey,
                              File(widget.filePath!),
                              // width: width,
                              // height: height,
                              fit: BoxFit.contain,
                            ),
                          ),
                          Positioned(
                            left: 0,
                            right: 0,
                            top: (isReverse ? offsetY : -offsetY),
                            child: Image.asset(
                              "assets/images/ic_swiper_shadow.png",
                              height: $(76),
                              width: _width,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                              left: 0,
                              right: 0,
                              top: (isReverse ? (_height - offsetY) + _height - $(76) : (offsetY - $(76))),
                              child: Transform.rotate(
                                  angle: pi,
                                  child: Image.asset(
                                    "assets/images/ic_swiper_shadow.png",
                                    height: $(76),
                                    width: _width,
                                    fit: BoxFit.cover,
                                  ))),
                          Positioned(
                            left: 0,
                            right: 0,
                            top: offsetY,
                            child: Image.asset(
                              "assets/images/ic_swiper_line.png",
                              height: $(3),
                              width: _width,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  Positioned(
                      top: $(13),
                      left: $(13),
                      child: Image.asset(
                        "assets/images/ic_corn.png",
                        width: $(32),
                      )),
                  Positioned(
                      top: $(13),
                      right: $(13),
                      child: Transform.rotate(
                          angle: pi / 2,
                          child: Image.asset(
                            "assets/images/ic_corn.png",
                            width: $(32),
                          ))),
                  Positioned(
                      bottom: $(13),
                      left: $(13),
                      child: Transform.rotate(
                          angle: -pi / 2,
                          child: Image.asset(
                            "assets/images/ic_corn.png",
                            width: $(32),
                          ))),
                  Positioned(
                      bottom: $(13),
                      right: $(13),
                      child: Transform.rotate(
                          angle: pi,
                          child: Image.asset(
                            "assets/images/ic_corn.png",
                            width: $(32),
                          ))),
                ],
              ),
            ),
          ),
          SizedBox(
            height: widget.bottomPadding - ScreenUtil.getBottomPadding(context),
          )
        ],
      ),
    );
  }
}

// 自定义裁剪器
class ReactClipper extends CustomClipper<Path> {
  ReactClipper(this.height);

  double height;

  @override
  Path getClip(Size size) {
    // 定义一个 Path 对象，用于描述裁剪区域的形状
    Path path = Path();
    // 使用 moveTo 和 lineTo 方法来描述裁剪区域的形状，这里是一个矩形
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, height);
    path.lineTo(0, height);
    // 关闭路径，形成闭合图形
    path.close();
    // 返回裁剪区域的形状
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true; // 不需要重新裁剪
  }
}
