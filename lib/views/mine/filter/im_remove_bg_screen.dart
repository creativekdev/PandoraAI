import 'dart:io';
import 'dart:math';

import 'package:cartoonizer/Controller/upload_image_controller.dart';
import 'package:common_utils/common_utils.dart';

import '../../../Common/importFile.dart';
import '../../../Widgets/app_navigation_bar.dart';
import '../../../api/filter_api.dart';
import '../../../network/dio_node.dart';

typedef OnGetRemoveBgImage = void Function(String removeBgUrl);

class ImRemoveBgScreen extends StatefulWidget {
  const ImRemoveBgScreen({super.key,
    required this.onGetRemoveBgImage,
    required this.filePath,
    required this.imageRatio,
    this.bottomPadding = 0,
    this.switchButtonBottomToScreen = 0,
    required this.imageHeight,
    required this.imageWidth});

  final String filePath;
  final OnGetRemoveBgImage onGetRemoveBgImage;
  final double imageRatio;
  final double bottomPadding;
  final double switchButtonBottomToScreen;
  final double imageHeight;
  final double imageWidth;

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
  late double width;
  late double height;
  UploadImageController uploadImageController = Get.find();
  GlobalKey globalKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // width = ScreenUtil.screenSize.width;
    // height = width / widget.imageRatio;
    width = widget.imageWidth;
    height = widget.imageHeight;
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

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      RenderBox containerBox = globalKey.currentContext!.findRenderObject() as RenderBox;
      width = containerBox.size.width;
      height = containerBox.size.height;
      print("width === $width");
      print(height);
      setState(() {

      });
    });
  }

  onGetRemovebgImage() async {
    uploadImageController.upload(file: File(widget.filePath)).then((value) async {
      if (TextUtil.isEmpty(value)) {
        isRequset = false;
        removeBgUrl = null;
      } else {
        removeBgUrl = await FilterApi(client: DioNode().build(logResponseEnable: false)).removeBgAndSave(
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xaa000000),
      appBar: AppNavigationBar(
        backgroundColor: Colors.transparent,
        leading: SizedBox(),
      ),
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
                      double offsetY = height * _animation.value;
                      return Stack(
                        children: [
                          ClipPath(
                            //  矩形裁剪
                            clipper: ReactClipper(isLoaded ? offsetY : height),
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
                              height: $(88),
                              width: width,
                            ),
                          ),
                          Positioned(
                              left: 0,
                              right: 0,
                              top: (isReverse ? (height - offsetY) + height - $(88) : (offsetY - $(88))),
                              child: Transform.rotate(
                                  angle: pi,
                                  child: Image.asset(
                                    "assets/images/ic_swiper_shadow.png",
                                    height: $(88),
                                    width: width,
                                  ))),
                          Positioned(
                            left: 0,
                            right: 0,
                            top: offsetY,
                            child: Image.asset(
                              "assets/images/ic_swiper_line.png",
                              height: $(3),
                              width: width,
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
