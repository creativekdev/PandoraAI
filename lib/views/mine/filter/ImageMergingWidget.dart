import 'dart:ui' as ui;

import 'package:cartoonizer/common/importFile.dart';
import 'package:image/image.dart' as imgLib;

import '../../../images-res.dart';

class ImageMergingWidget extends StatefulWidget {
  imgLib.Image personImage;
  imgLib.Image? backgroundImage;
  Color? backgroundColor;
  ui.Image personImageForUI;
  late double posX, posY, ratio;
  Uint8List? personByte, backgroundByte;
  final Function(imgLib.Image) onAddImage;

  ImageMergingWidget({
    required this.personImage,
    required this.personImageForUI,
    required this.backgroundImage,
    required this.backgroundColor,
    required this.onAddImage,
  }) {
    personByte = Uint8List.fromList(imgLib.encodePng(personImage));
    if (backgroundImage != null) {
      backgroundByte = Uint8List.fromList(imgLib.encodePng(backgroundImage!));
    }
    posX = posY = 0;
    ratio = 1;
  }

  @override
  _ImageMergingWidgetState createState() => _ImageMergingWidgetState();
}

class _ImageMergingWidgetState extends State<ImageMergingWidget> {
  @override
  Widget build(BuildContext context) {
    Size size = ScreenUtil.getCurrentWidgetSize(context);
    double W, H, w1, h1, w2, h2;
    double r1, r2;
    W = size.width;
    H = size.height;
    w1 = widget.backgroundImage?.width.toDouble() ?? W;
    h1 = widget.backgroundImage?.height.toDouble() ?? H;
    w2 = widget.personImage.width.toDouble();
    h2 = widget.personImage.height.toDouble();
    if (w1 / h1 > W / H)
      r1 = w1 / W;
    else
      r1 = h1 / H;
    if (w2 / h2 > W / H)
      r2 = w2 / W;
    else
      r2 = h2 / H;

    return GestureDetector(
        onPanStart: (details) {},
        onPanUpdate: (details) {
          setState(() {
            widget.posX += details.delta.dx;
            widget.posY += details.delta.dy;
          });
        },
        onPanEnd: (details) {},
        child: Stack(
          children: [
            widget.backgroundByte != null
                ? Container(
                    width: size.width,
                    height: size.height,
                    child: Image.memory(
                      widget.backgroundByte!,
                      fit: BoxFit.contain,
                    ),
                  )
                : SizedBox(
                    width: size.width,
                    height: size.height,
                  ),
            Container(
                child: CustomPaint(
              painter: AlphaImagePainter(widget.personImageForUI, dx: widget.posX, dy: widget.posY, ratio: widget.ratio),
              child: Container(
                width: size.width,
                height: size.height,
              ), // You can replace this with your own UI elements
            )),
            Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                    height: $(50),
                    child: Row(
                      children: [
                        Expanded(
                            child: Slider(
                          value: widget.ratio,
                          min: 0.2,
                          max: 5,
                          onChanged: (double newValue) {
                            setState(() {
                              widget.ratio = newValue;
                            });
                          },
                        )),
                        InkWell(
                          onTap: () async {
                            imgLib.Image res_image;
                            if (widget.backgroundImage != null) {
                              res_image = widget.backgroundImage!;
                            } else {
                              res_image = imgLib.Image(widget.personImage.width, widget.personImage.height);
                              imgLib.fill(res_image, rgbaToAbgr(widget.backgroundColor!).value);
                            }
                            imgLib.Image person_image = widget.personImage;
                            for (int i = 0; i < res_image.width; i++) {
                              for (int j = 0; j < res_image.height; j++) {
                                var pixel1 = res_image.getPixel(i, j);

                                double ii = W / 2 - (w1 / 2 - i) / r1;
                                double jj = H / 2 - (h1 / 2 - j) / r1;
                                double iiid = (ii - widget.posX - W / 2) / widget.ratio + w2 / 2;
                                double jjjd = (jj - widget.posY - H / 2) / widget.ratio + h2 / 2;
                                int iii = iiid.toInt();
                                int jjj = jjjd.toInt();
                                if (0 <= iii && iii < person_image.width && 0 <= jjj && jjj < person_image.height) {
                                  var pixel2 = person_image.getPixel(iii, jjj);
                                  double alpha2 = imgLib.getAlpha(pixel2) / 255;
                                  int red = (imgLib.getRed(pixel1) * (1 - alpha2) + imgLib.getRed(pixel2) * alpha2).toInt();
                                  int green = (imgLib.getGreen(pixel1) * (1 - alpha2) + imgLib.getGreen(pixel2) * alpha2).toInt();
                                  int blue = (imgLib.getBlue(pixel1) * (1 - alpha2) + imgLib.getBlue(pixel2) * alpha2).toInt();
                                  res_image.setPixelRgba(i, j, red, green, blue);
                                }
                              }
                            }
                            widget.onAddImage(res_image);
                          },
                          child: Image.asset(Images.ic_confirm),
                        )
                      ],
                    )))
          ],
        ));
  }

  Color rgbaToAbgr(Color rgbaColor) {
    int abgrValue = (rgbaColor.alpha << 24) | (rgbaColor.blue << 16) | (rgbaColor.green << 8) | rgbaColor.red;
    return Color(abgrValue);
  }
}

class AlphaImagePainter extends CustomPainter {
  final ui.Image personImageForUI;
  double dx, dy, ratio;

  AlphaImagePainter(this.personImageForUI, {required this.dx, required this.dy, required this.ratio});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(dx + size.width / 2 - personImageForUI.width * ratio / 2, dy + size.height / 2 - personImageForUI.height * ratio / 2);
    canvas.scale(ratio);

    canvas.drawImage(personImageForUI, Offset(0, 0), Paint());
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
