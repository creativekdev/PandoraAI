import 'dart:io';
import 'dart:typed_data';

import 'package:cartoonizer/Widgets/gallery/pick_album.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/utils/dialog_util.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:cartoonizer/views/ai/anotherme/anotherme.dart';
import 'package:cartoonizer/views/ai/drawable/widget/drawable.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:opencv_4/factory/pathfrom.dart';
import 'package:opencv_4/opencv_4.dart';

//uncomment when image_picker is installed
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';
import 'package:image/image.dart' as imgLib;

import '../../../Widgets/gallery/crop_screen.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({Key? key}) : super(key: key);

  @override
  _FilterScreenState createState() => _FilterScreenState();
}

class _FilterScreenState extends AppState<FilterScreen> {
  File? _imagefile;
  late imgLib.Image _image;
  late Size _imageSize;
  CropController cropController = CropController();
  CacheManager cacheManager = AppDelegate.instance.getManager();

  bool _iscrop = false;
  Uint8List? _byte;
  String _versionOpenCV = 'OpenCV';
  bool _visible = false;
  List<String> filters = [
    "normal",
    "discolor",
    "invert",
    "EdgeDetection",
    "Sharpen",
    "OldTimeFilter",
    "BlackWhite",
    "RemoveColor",
    "FusedFilter",
    "FreezeFilter",
    "ComicstripFilter",
    "Crop"
  ];

  //uncomment when image_picker is installed
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _getOpenCVVersion();
  }

  testOpenCV({
    required String pathString,
    required CVPathFrom pathFrom,
    required double thresholdValue,
    required double maxThresholdValue,
    required int thresholdType,
  }) async {
    try {
      //test with threshold
      _byte = await Cv2.threshold(
        pathFrom: pathFrom,
        pathString: pathString,
        maxThresholdValue: maxThresholdValue,
        thresholdType: thresholdType,
        thresholdValue: thresholdValue,
      );

      setState(() {
        _byte;
        _visible = false;
      });
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  /// metodo que devuelve la version de OpenCV utilizada
  Future<void> _getOpenCVVersion() async {
    String? versionOpenCV = await Cv2.version();
    setState(() {
      _versionOpenCV = 'OpenCV: ' + versionOpenCV!;
    });
  }

  _setURL() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    _imagefile = File(pickedFile!.path);
//    final ByteData data = await rootBundle.load(pickedFile.path);
    _image = await getLibImage(await getImage(_imagefile!));
    _imageSize = Size(_image.width.toDouble(), _image.height.toDouble());
    _byte = Uint8List.fromList(imgLib.encodeJpg(_image));

    setState(() {
      _imagefile;
//      _imageData = data.buffer.asUint8List();
//      _image = MemoryImage(_imageData);
//      _byte = _image;
    });
  }
  int getR(int pixel) {
    return  pixel & 0xFF;
  }
  int getG(int pixel) {
    return  (pixel >> 8) & 0xFF;
  }
  int getB(int pixel) {
    return  (pixel >> 16) & 0xFF;
  }
  setRGB(int pixel, int r, int g, int b){
    if(r > 255) r= 255;
    else if(r < 0) r = 0;
    if(g > 255) g= 255;
    else if(g < 0) g = 0;
    if(b > 255) b= 255;
    else if(b < 0) b = 0;

    return (pixel & 0xFF000000) | ((b << 16) & 0x00FF0000) | ((g <<
        8) & 0x0000FF00) | ((r) & 0x000000FF);
  }
  //This is spacial filter, not so good, should use FFT and IFT to speed up.
  convolution(imgLib.Image image, List<int> kernel)
  {
    List<int> di = [-1, 0, 1, -1, 0, 1, -1, 0, 1];
    List<int> dj = [-1, -1, -1, 0, 0, 0, 1, 1, 1];
    imgLib.Image  __image = imgLib.copyCrop(image, 0, 0, image.width, image.height);

    for (int i = 1; i < image.width - 1; i++) {
      for (int j = 1; j < image.height - 1; j++) {
        int valr, valb, valg;
        valr = valb = valg = 0;
        for (int c = 0; c < 9; c ++) {
          int pixel = image.getPixel(i + di[c], j + dj[c]);
          valr = valr + getR(pixel) * kernel[c];
          valg = valg + getG(pixel) * kernel[c];
          valb = valb + getB(pixel) * kernel[c];
        }
        __image.setPixel(i, j, setRGB(image.getPixel(i, j), valr, valg, valb));
      }
    }
    return __image;
  }

  _Filter(String filter) async {
    //uncomment when image_picker is installed
    if (_imagefile != null) {
      try {
        //test with threshold
        switch (filter) {
          case "normal":
            _byte = Uint8List.fromList(imgLib.encodeJpg(_image));
            break;
          case "discolor":
            _byte = await Cv2.cvtColor(
                pathFrom: CVPathFrom.GALLERY_CAMERA,
                pathString: _imagefile!.path,
                outputType: Cv2.COLOR_BGR2GRAY);
            break;
          case "invert":
            imgLib.Image  __image = imgLib.copyCrop(_image, 0, 0, _image.width, _image.height);
            for (int i = 0; i < __image.width; i++) {
              for (int j = 0; j < __image.height; j++) {
                var pixel = __image.getPixel(i, j);
                int r = getR(pixel);
                int g = getG(pixel);
                int b = getB(pixel);
                r = 255 - r;
                g = 255 - g;
                b = 255 - b;
                pixel = setRGB(pixel, r, g, b);
                __image.setPixel(i, j, pixel);
              }
            }
            _byte = Uint8List.fromList(imgLib.encodeJpg(__image));
            break;
          case "EdgeDetection":
            _byte = await Cv2.laplacian(
                pathFrom: CVPathFrom.GALLERY_CAMERA,
                pathString: _imagefile!.path,
                depth:Cv2.CV_SCHARR);
            break;
          case "Sharpen":
            List<int> kernel = [-1, -1, -1, -1, 9, -1, -1, -1, -1];
            imgLib.Image  __image = imgLib.copyCrop(_image, 0, 0, _image.width, _image.height);
            __image = convolution(__image, kernel);
            _byte = Uint8List.fromList(imgLib.encodeJpg(__image));
            break;
          case "OldTimeFilter":
            imgLib.Image  __image = imgLib.copyCrop(_image, 0, 0, _image.width, _image.height);
            for (int i = 0; i < __image.width; i++) {
              for (int j = 0; j < __image.height; j++) {
                var pixel = __image.getPixel(i, j);
                int r = getR(pixel);
                int g = getG(pixel);
                int b = getB(pixel);
                int newR = (0.393 * r + 0.769 * g + 0.189 * b).toInt();
                int newG = (0.349 * r + 0.686 * g + 0.168 * b).toInt();
                int newB = (0.272 * r + 0.534 * g + 0.131 * b).toInt();
                pixel = setRGB(pixel, newR, newG, newB);
                __image.setPixel(i, j, pixel);
              }
            }
            _byte = Uint8List.fromList(imgLib.encodeJpg(__image));
            break;
          case "BlackWhite":
            _byte = await Cv2.threshold(
              pathFrom: CVPathFrom.GALLERY_CAMERA,
              pathString: _imagefile!.path,
              maxThresholdValue: 200,
              thresholdType: Cv2.THRESH_BINARY,
              thresholdValue: 150,
            );
            break;
          case "RemoveColor":
            _byte = await Cv2.cvtColor(
                pathFrom: CVPathFrom.GALLERY_CAMERA,
                pathString: _imagefile!.path,
                outputType: Cv2.COLOR_BGR2GRAY);
            break;
          case "FusedFilter":
            imgLib.Image  __image = imgLib.copyCrop(_image, 0, 0, _image.width, _image.height);
            for (int i = 0; i < __image.width; i++) {
              for (int j = 0; j < __image.height; j++) {
                var pixel = __image.getPixel(i, j);
                int r = getR(pixel);
                int g = getG(pixel);
                int b = getB(pixel);
                int newR = ((r * 128) / (g + b + 1)).toInt();
                int newG = ((g * 128) / (r + b + 1)).toInt();
                int newB = ((b * 128) / (g + r + 1)).toInt();
                pixel = setRGB(pixel, newR, newG, newB);
                __image.setPixel(i, j, pixel);
              }
            }
            _byte = Uint8List.fromList(imgLib.encodeJpg(__image));
            break;
          case "FreezeFilter":
            imgLib.Image  __image = imgLib.copyCrop(_image, 0, 0, _image.width, _image.height);
            for (int i = 0; i < __image.width; i++) {
              for (int j = 0; j < __image.height; j++) {
                var pixel = __image.getPixel(i, j);
                int r = getR(pixel);
                int g = getG(pixel);
                int b = getB(pixel);
                int newR = (((r - g - b) * 3) / 2).toInt();
                int newG = (((g - r - b) * 3) / 2).toInt();
                int newB = (((b - g - r) * 3) / 2).toInt();
                pixel = setRGB(pixel, newR, newG, newB);
                __image.setPixel(i, j, pixel);
              }
            }
            _byte = Uint8List.fromList(imgLib.encodeJpg(__image));
            break;
          case "ComicstripFilter":
            imgLib.Image  __image = imgLib.copyCrop(_image, 0, 0, _image.width, _image.height);
            for (int i = 0; i < __image.width; i++) {
              for (int j = 0; j < __image.height; j++) {
                var pixel = __image.getPixel(i, j);
                int r = getR(pixel);
                int g = getG(pixel);
                int b = getB(pixel);
                int newR = (((g - b + g + r).abs() * r) / 256).toInt();
                int newG = (((b - g + b + r).abs() * r) / 256).toInt();
                int newB = (((b - g + b + r).abs() * g) / 256).toInt();
                pixel = setRGB(pixel, newR, newG, newB);
                __image.setPixel(i, j, pixel);
              }
            }
            _byte = Uint8List.fromList(imgLib.encodeJpg(__image));
            break;
          case "Crop":
            AnotherMe.checkPermissions().then((value) async {
              bool fromCamera = false;
              // if (value) {
              XFile? result;
              if (fromCamera) {
                var pickImage = await ImagePicker().pickImage(source: ImageSource.camera, maxWidth: 512, maxHeight: 512, preferredCameraDevice: CameraDevice.rear, imageQuality: 100);
                if (pickImage != null) {
                  result = await CropScreen.crop(context, image: pickImage, brightness: Brightness.light);
                }
              } else {
                final pickedFile = await picker.getImage(source: ImageSource.gallery);
                result = await CropScreen.crop(context, image: XFile(pickedFile!.path), brightness: Brightness.light);
              }
              if (result != null) {
                _imagefile = File(result!.path);
//    final ByteData data = await rootBundle.load(pickedFile.path);
                _image = await getLibImage(await getImage(_imagefile!));
                setState(() {
                  _imagefile;
                });
              }
              // } else {
              //   showPhotoLibraryPermissionDialog(context);
              // }
            });
            break;
          default:
        }

        setState(() {
          _byte;
          _visible = false;
        });
      } on PlatformException catch (e) {
        print(e.message);
      }
    }
  }

  Widget getButtonWidgets() {
    List<Widget> list = <Widget>[];
    for (var i = 0; i < filters.length; i++) {
      list.add(Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: 40,
          width: 80.w,
          child: TextButton(
            child: Text(filters[i]),
            onPressed: () {
              _Filter(filters[i]);
            },
            style: TextButton.styleFrom(
              primary: Colors.white,
              backgroundColor: Colors.teal,
              onSurface: Colors.grey,
            ),
          ),
        ),
      ));
    }
    return Column(children: list);
  }

  onCroped(Uint8List bytes) {
    hideLoading().whenComplete(() async {
      String filePath = cacheManager.storageOperator.tempDir.path + 'crop-screen${DateTime.now().millisecondsSinceEpoch}.png';
      var file = File(filePath);

      if (file.existsSync()) {
        file.deleteSync();
      }
      await file.writeAsBytes(bytes);
      hideLoading().whenComplete(() async {
        _imagefile = File(filePath);
        _image = await getLibImage(await getImage(_imagefile!));
        _imageSize = Size(_image.width.toDouble(), _image.height.toDouble());
        setState(() {
          _imagefile;
          _iscrop = false;
        });

      });


    });
  }
  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Filter test"),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Container(
                  margin: EdgeInsets.only(top: 20),
                  child: Center(
                    child: Column(
                      children: <Widget>[
                        // Text(
                        //   _versionOpenCV,
                        //   style: TextStyle(fontSize: 23),
                        // ),
                        Container(
                          margin: EdgeInsets.only(top: 5),
                          child: _byte != null
                              ? _iscrop
                              ?Crop(
                              image: _byte!,
                              initialArea: Rect.fromLTWH(_imageSize!.width / 4, _imageSize!.height / 4, _imageSize!.width / 2, _imageSize!.width / 2),
                              controller: cropController,
                              onCropped: (bytes) {
                                onCroped(bytes);
                              }):Image.memory(
                                  _byte!,
                                  width: 300,
                                  height: 300,
                                  fit: BoxFit.fill,
                                )
                              : _imagefile != null
                                  ? Container(
                                      width: 300,
                                      height: 300,
                                      child: Image.file(_imagefile!),
                                    )
                                  : Container(
                                      width: 300,
                                      height: 300,
                                      child: Icon(
                                        Icons.camera_alt,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                        ),
                        Visibility(
                            maintainAnimation: true,
                            maintainState: true,
                            visible: _visible,
                            child:
                                Container(child: CircularProgressIndicator())),
                        SizedBox(
                          width: MediaQuery.of(context).size.width - 40,
                          child: TextButton(
                            child: Text('slectImage'),
                            onPressed: _setURL,
                            style: TextButton.styleFrom(
                              primary: Colors.white,
                              backgroundColor: Colors.teal,
                              onSurface: Colors.grey,
                            ),
                          ),
                        ),
                        getButtonWidgets()
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
