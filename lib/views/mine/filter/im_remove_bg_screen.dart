import 'dart:io';

import '../../../Common/importFile.dart';
import '../../../api/filter_api.dart';
import '../../../network/dio_node.dart';

typedef OnGetRemoveBgImage = void Function(String removeBgUrl);

class ImRemoveBgScreen extends StatefulWidget {
  const ImRemoveBgScreen({super.key, required this.imageUrl, required this.onGetRemoveBgImage, required this.filePath, required this.imageRatio});

  final String imageUrl;
  final String filePath;
  final OnGetRemoveBgImage onGetRemoveBgImage;
  final double imageRatio;

  @override
  State<ImRemoveBgScreen> createState() => _ImRemoveBgScreenState();
}

class _ImRemoveBgScreenState extends State<ImRemoveBgScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool isRequset = true;
  bool isLoaded = false;
  String? removeBgUrl;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _controller.addStatusListener((status) {
      switch (status) {
        case AnimationStatus.forward:
          if (isRequset == false && isLoaded == true) {
            _controller.stop();
            widget.onGetRemoveBgImage(removeBgUrl!);
            Future.delayed(Duration(milliseconds: 300), () {
              Navigator.of(context).pop(true);
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
          break;
        case AnimationStatus.dismissed:
          _controller.forward();
          break;
      }
    });
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
    onGetRemovebgImage();
  }

  onGetRemovebgImage() async {
    removeBgUrl = await FilterApi(client: DioNode().build(logResponseEnable: false)).removeBgAndSave(
        imageUrl: widget.imageUrl,
        onFailed: (response) {
          Navigator.of(context).pop(false);
        });
    if (removeBgUrl != null) {
      isRequset = false;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0x7f000000),
      body: Center(
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            if (isLoaded == true) // 显示生成的图片
              Image.file(
                File(removeBgUrl!),
                width: $(300),
                height: $(300) * widget.imageRatio,
                fit: BoxFit.cover,
              ),
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                double height = $(300) * widget.imageRatio;
                double offsetY = height * _animation.value;
                return Stack(
                  children: [
                    ClipPath(
                      //  矩形裁剪
                      clipper: ReactClipper(isLoaded ? offsetY : $(300) * widget.imageRatio),
                      child: Image.file(
                        File(widget.filePath!),
                        width: $(300),
                        height: $(300) * widget.imageRatio,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      top: offsetY,
                      child: Container(
                        height: $(2),
                        color: Colors.red,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
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
