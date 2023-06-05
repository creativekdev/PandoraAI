import 'dart:io';
import 'dart:typed_data';

import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:opencv_4/factory/pathfrom.dart';
import 'package:opencv_4/opencv_4.dart';

//uncomment when image_picker is installed
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({Key? key}) : super(key: key);

  @override
  _FilterScreenState createState() => _FilterScreenState();
}

class _FilterScreenState extends AppState<FilterScreen> {
  File? _image;
  late Uint8List _imageData;
  Uint8List? _byte;
  String _versionOpenCV = 'OpenCV';
  bool _visible = false;
  List<String> filters = [
    "normal",
    "discolor",
    "invert",
    "dodgeColor",
    "gaussBlur",
    "EdgeDetection",
    "Sharpen",
    "OldTimeFilter",
    "BlackWhite",
    "RemoveColor",
    "FusedFilter",
    "FreezeFilter",
    "ComicstripFilter",
    "Sketch",
    "TestLutFilter"
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
    _image = File(pickedFile!.path);
    final ByteData data = await rootBundle.load(pickedFile.path);
    setState(() {
      _imageData = data.buffer.asUint8List();
      _byte = data.buffer.asUint8List();
    });
  }

  _Filter(String filter) async {
    //uncomment when image_picker is installed
    if (_image != null) {
      try {
        //test with threshold
        switch (filter) {
          case "normal":
            _byte = _imageData;
            break;
          case "discolor":
            _byte = await Cv2.cvtColor(
                pathFrom: CVPathFrom.GALLERY_CAMERA,
                pathString: _image!.path,
                outputType: Cv2.COLOR_BGR2GRAY);
            break;
          case "invert":
            break;
          case "dodgeColor":
            break;
          case "EdgeDetection":
            break;

          case "gaussBlur":
            _byte = await Cv2.gaussianBlur(
                pathFrom: CVPathFrom.GALLERY_CAMERA,
                pathString: _image!.path,
                kernelSize: [6, 6],
                sigmaX: 2);
            break;
          case "BlackWhite":
            _byte = await Cv2.threshold(
              pathFrom: CVPathFrom.GALLERY_CAMERA,
              pathString: _image!.path,
              maxThresholdValue: 200,
              thresholdType: Cv2.THRESH_BINARY,
              thresholdValue: 150,
            );
            break;
          case "invert":
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
                              ? Image.memory(
                                  _byte!,
                                  width: 300,
                                  height: 300,
                                  fit: BoxFit.fill,
                                )
                              : _image != null
                                  ? Container(
                                      width: 300,
                                      height: 300,
                                      child: Image.file(_image!),
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
