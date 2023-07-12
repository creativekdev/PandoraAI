
import 'dart:io';

import 'package:cartoonizer/Common/importFile.dart';
import 'package:image/image.dart' as imgLib;
import 'dart:ui' as ui;

import '../../../images-res.dart';

class ImageMergingWidget extends StatefulWidget {
  imgLib.Image personImage, backgroundImage;
  ui.Image personImageForUI;
  late double posX, posY, ratio;
  Uint8List? personByte, backgroundByte;
  final Function(imgLib.Image) onAddImage;
  ImageMergingWidget({required this.personImage, required this.personImageForUI, required this.backgroundImage, required this.onAddImage}) {
    personByte = Uint8List.fromList(imgLib.encodeJpg(personImage));
    backgroundImage = imgLib.copyResize(backgroundImage, width: personImage.width, height: personImage.height);
    backgroundByte = Uint8List.fromList(imgLib.encodeJpg(backgroundImage));
    posX = posY = 0;
    ratio = 1;
  }

  @override
  _ImageMergingWidgetState createState() => _ImageMergingWidgetState();
}

class _ImageMergingWidgetState extends State<ImageMergingWidget> {

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {

      },
      onPanUpdate: (details){
        setState(() {
          widget.posX += details.delta.dx;
          widget.posY += details.delta.dy;
        });

      },
      onPanEnd: (details) {

      },
      child: Stack(
        children: [
          Column(
            children: [
            Expanded(
              child: Row(
                children: [
                Expanded(
                child: Container(
                  margin: EdgeInsets.only(top: $(5)),
                  child: Image.memory(
                      widget.backgroundByte!,
                      fit: BoxFit.contain,
                    ),
                  ))
                ]
              )
            )]
          ),
          CustomPaint(
            painter: AlphaImagePainter(widget.personImageForUI!, dx: widget.posX, dy: widget.posY, ratio: widget.ratio ),
            child: Container(
            ), // You can replace this with your own UI elements
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: $(50),
              child: Row(
               children: [
                 Expanded(child: Slider(
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
                     imgLib.Image res_image = imgLib.copyResize(widget.backgroundImage, width: widget.backgroundImage.width, height: widget.backgroundImage.height);
                     imgLib.Image person_image = imgLib.copyResize(widget.personImage, width: (widget.personImage.width * widget.ratio).toInt(), height: (widget.personImage.height* widget.ratio).toInt());
                     for (int i = 0; i < res_image.width; i++) {
                       for (int j = 0; j < res_image.height; j++) {
                         var pixel1 = res_image.getPixel(i, j);
                         int ii = i - widget.posX.toInt();
                         int jj = j - widget.posY.toInt();
                         if(0<=ii && ii <person_image.width && 0<=jj && jj < person_image.height) {
                           var pixel2 = person_image.getPixel(ii, jj);
                           double alpha2 = imgLib.getAlpha(pixel2)/255;
                           int red = (imgLib.getRed(pixel1)*(1- alpha2) + imgLib.getRed(pixel2) * alpha2).toInt();
                           int green = (imgLib.getGreen(pixel1)*(1- alpha2) + imgLib.getGreen(pixel2) * alpha2).toInt();
                           int blue = (imgLib.getBlue(pixel1)*(1- alpha2) + imgLib.getBlue(pixel2) * alpha2).toInt();
                           res_image.setPixelRgba(i, j, red, green, blue);
                         }
                       }
                     }
                     widget.onAddImage(res_image);
                   },
                   child: Image.asset(Images.ic_confirm),
                 )
               ],
              )
            )
          )
        ],
      )
    );

  }

}




class AlphaImagePainter extends CustomPainter {
  final ui.Image personImageForUI;
  double dx, dy, ratio;
  AlphaImagePainter(this.personImageForUI, {required this.dx, required this.dy, required this.ratio});

  @override
  void paint(Canvas canvas, Size size)  {

    final Size imageSize = Size(
      personImageForUI.width.toDouble(),
      personImageForUI.height.toDouble(),
    );

    final FittedSizes sizes = applyBoxFit(BoxFit.contain, imageSize, size);
    final Rect sourceRect =
    Alignment.center.inscribe(sizes.source, Offset.zero & imageSize);
    final Rect destinationRect =
    Alignment.center.inscribe(sizes.destination, Offset.zero & size);

    canvas.translate(dx, dy);
    canvas.scale(ratio);
    canvas.drawImageRect(personImageForUI, sourceRect, destinationRect, Paint());
  }



  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}