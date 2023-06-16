
import 'dart:io';

import 'package:cartoonizer/Common/Extension.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Controller/ChoosePhotoScreenController.dart';
import 'package:cartoonizer/Controller/effect_data_controller.dart';
import 'package:cartoonizer/Controller/upload_image_controller.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/cacheImage/cached_network_image_utils.dart';
import 'package:cartoonizer/Widgets/image/sync_image_provider.dart';
import 'package:cartoonizer/Widgets/outline_widget.dart';
import 'package:cartoonizer/Widgets/video/effect_video_player.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/models/OfflineEffectModel.dart';
import 'package:cartoonizer/models/api_config_entity.dart';
import 'package:cartoonizer/models/upload_record_entity.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:cartoonizer/views/mine/filter/GridSlider.dart';
import 'package:cartoonizer/views/transfer/pick_photo_screen.dart';
import 'package:common_utils/common_utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:opencv_4/factory/pathfrom.dart';
import 'package:opencv_4/opencv_4.dart';
import 'package:image/image.dart' as imgLib;


class ImFilterScreen extends StatefulWidget {
  // int tabPos;
  // int pos;
  // int itemPos;
  // EntrySource entrySource;
  // RecentEffectModel? recentEffectModel;

  ImFilterScreen({
    Key? key
  }) : super(key: key);

  @override
  _ImFilterScreenState createState() => _ImFilterScreenState();
}

class _ImFilterScreenState extends State<ImFilterScreen> with SingleTickerProviderStateMixin {
  bool isLoading = true;
  File? _imagefile;
  late imgLib.Image _image;
  late Size _imageSize;
  Uint8List? _byte;
  List<String> filters = [
    "NOR",
    "DIS",
    "INV",
    "EDG",
    "SHR",
    "OLD",
    "BLK",
    "RMV",
    "FUS",
    "FRZ",
    "CMC",
  ];
  final picker = ImagePicker();

  // List<ChooseTabItemInfo> tabItemList = [];
  late ItemScrollController itemScrollController;
  final ItemPositionsListener itemScrollPositionsListener = ItemPositionsListener.create();
  late double itemWidth;
  var currentItemIndex = 0.obs;
  List<String> _rightTabList = [Images.ic_effect, Images.ic_filter, Images.ic_adjust,Images.ic_crop, Images.ic_background, Images.ic_letter];
  int selectedRightTab = 0;

  int selectedEffectID = 0;
  int selectedFilterID = 0;

  int currentAdjustID = 0;

  int selectedCropID = 0;

  late ImagePicker imagePicker;

  List<ChooseTabItemInfo> tabItemList = [];


  ChoosePhotoScreenController controller = Get.put(ChoosePhotoScreenController());
  UploadImageController uploadImageController = Get.put(UploadImageController());
  Map<String, OfflineEffectModel> offlineEffect = {};
  Map<String, GlobalKey<EffectVideoPlayerState>> videoKeys = {};

  @override
  void initState() {
    super.initState();
    isLoading = false;
    itemScrollController = ItemScrollController();
    itemWidth = (ScreenUtil.screenSize.width - $(90)) / 5;
    imagePicker = ImagePicker();

  }

  @override
  void dispose() {
    super.dispose();
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
          case "NOR":
            _byte = Uint8List.fromList(imgLib.encodeJpg(_image));
            break;
          case "DIS":
            _byte = await Cv2.cvtColor(
                pathFrom: CVPathFrom.GALLERY_CAMERA,
                pathString: _imagefile!.path,
                outputType: Cv2.COLOR_BGR2GRAY);
            break;
          case "INV":
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
          case "EDG":
            _byte = await Cv2.laplacian(
                pathFrom: CVPathFrom.GALLERY_CAMERA,
                pathString: _imagefile!.path,
                depth:Cv2.CV_SCHARR);
            break;
          case "SHR":
            List<int> kernel = [-1, -1, -1, -1, 9, -1, -1, -1, -1];
            imgLib.Image  __image = imgLib.copyCrop(_image, 0, 0, _image.width, _image.height);
            __image = convolution(__image, kernel);
            _byte = Uint8List.fromList(imgLib.encodeJpg(__image));
            break;
          case "OLD":
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
          case "BLK":
            _byte = await Cv2.threshold(
              pathFrom: CVPathFrom.GALLERY_CAMERA,
              pathString: _imagefile!.path,
              maxThresholdValue: 200,
              thresholdType: Cv2.THRESH_BINARY,
              thresholdValue: 150,
            );
            break;
          case "RMV":
            _byte = await Cv2.cvtColor(
                pathFrom: CVPathFrom.GALLERY_CAMERA,
                pathString: _imagefile!.path,
                outputType: Cv2.COLOR_BGR2GRAY);
            break;
          case "FUS":
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
          case "FRZ":
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
          case "CMC":
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
          default:
        }

        setState(() {
          _byte;
          // _visible = false;
        });
      } on PlatformException catch (e) {
        print(e.message);
      }
    }
  }



  Widget _buildRightTab() {
    List<Widget> buttons = [];
    int num  = 0;
    for(var img in _rightTabList) {
      int cur = num;
      buttons.add(GestureDetector(
        onTap: () {
          // Handle button press
          setState(() {
            selectedRightTab = cur;
          });
        },
        child: Container(
          width: 50,
          height: 50,
          decoration: (selectedRightTab == cur)?
          BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [const Color(0xFF68F0AF),const Color(0xFF05E0D5)],
            ),
            borderRadius: BorderRadius.circular(25),
            // image: DecorationImage(
            //   image: AssetImage(img),
            //   fit: BoxFit.cover,
            // ),
          ):
          BoxDecoration(
            borderRadius: BorderRadius.circular(25),
          ),
          child: FractionallySizedBox(
            widthFactor: 0.5,
            heightFactor: 0.5,
            child: DecoratedBox(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(img),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
      ));
      num++;
    }
    List<Widget> adjustbutton = [];
    adjustbutton.add(GestureDetector(
      onTap: () {
        // Handle button press
      },
      child: Container(
        width: 50,
        height: 50,
        decoration:
        BoxDecoration(
          borderRadius: BorderRadius.circular(25),
        ),
        child: FractionallySizedBox(
          widthFactor: 0.5,
          heightFactor: 0.5,
          child: DecoratedBox(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(Images.ic_reduction),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    ));
    return Align(
      alignment: Alignment.centerRight,
      child: Wrap(
        direction: Axis.vertical,
          spacing: 40,
        children: [
          Container(
            decoration: BoxDecoration(
                color: Color.fromARGB(100, 22, 44, 33),
                borderRadius: BorderRadius.all(Radius.circular(50))
            ),
            padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
            margin: const EdgeInsets.only(right: 10.0),
            height: 320,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: buttons
            )
          ),
          Container(
            decoration: BoxDecoration(
                color: Color.fromARGB(100, 22, 44, 33),
                borderRadius: BorderRadius.all(Radius.circular(50))
            ),
            padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
            margin: const EdgeInsets.only(right: 10.0),
            height: 60,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: adjustbutton
            )
          )
        ])

    );

  }

  Widget _imageWidget(BuildContext context, {required String imageUrl}) {
    return CachedNetworkImageUtils.custom(
      useOld: true,
      context: context,
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      height: itemWidth,
      width: itemWidth,
      placeholder: (context, url) {
        return Container(
          height: itemWidth,
          width: itemWidth,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
      errorWidget: (context, url, error) {
        return Container(
          height: itemWidth,
          width: itemWidth,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  Widget _createEffectModelIcon(BuildContext context, {required EffectItem effectItem, required bool checked}) {
    if (effectItem.imageUrl.contains("mp4")) {
      var key = videoKeys[effectItem.imageUrl];
      if (key == null) {
        key = GlobalKey<EffectVideoPlayerState>();
        videoKeys[effectItem.imageUrl] = key;
      }
      if (checked) {
        delay(() => key!.currentState?.play(), milliseconds: 32);
      } else {
        key.currentState?.pause();
      }
      return Container(
        width: itemWidth,
        height: itemWidth,
        child: EffectVideoPlayer(
          url: effectItem.imageUrl,
          key: key,
        ),
      );
    } else {
      return _imageWidget(context, imageUrl: effectItem.imageUrl);
    }
  }

  Future<bool> pickImageFromCamera(BuildContext context, {String from = "center"}) async {
    var source = ImageSource.camera;
    try {
      XFile? image = await imagePicker.pickImage(source: source, imageQuality: 100, preferredCameraDevice: CameraDevice.front);
      if (image == null) {
        CommonExtension().showToast("cancelled");
        return false;
      }
      controller.changeIsLoading(true);
      File compressedImage = await imageCompressAndGetFile(File(image.path));

      offlineEffect.clear();
      controller.updateImageFile(compressedImage);
      controller.updateImageUrl("");
      controller.changeIsPhotoSelect(true);
      controller.changeIsPhotoDone(false);
      // getCartoon(context);
      return true;
    } on PlatformException catch (error) {
      if (error.code == "camera_access_denied") {
        showCameraPermissionDialog(context);
      }
    } catch (error) {
      CommonExtension().showToast("Try to select valid image");
    }
    return false;
  }

  Future<bool> pickImageFromGallery(BuildContext context, {String from = "center", File? file, UploadRecordEntity? entity}) async {
    var source = ImageSource.gallery;
    try {
      File compressedImage;
      if (file != null) {
        compressedImage = await imageCompressAndGetFile(file);
        if (controller.image.value != null) {
          File oldFile = controller.image.value as File;
          if ((await md5File(oldFile)) == (await md5File(compressedImage))) {
            CommonExtension().showToast(S.of(context).photo_select_already);
            return false;
          }
        }
        controller.updateImageFile(compressedImage);
        controller.updateImageUrl("");
      } else if (entity == null) {
        XFile? image = await imagePicker.pickImage(source: source, imageQuality: 100, preferredCameraDevice: CameraDevice.front);
        if (image == null) {
          CommonExtension().showToast("cancelled");
          return false;
        }
        compressedImage = await imageCompressAndGetFile(File(image.path));
        if (controller.image.value != null) {
          File oldFile = controller.image.value as File;
          if ((await md5File(oldFile)) == (await md5File(compressedImage))) {
            CommonExtension().showToast(S.of(context).photo_select_already);
            return false;
          }
        }
        controller.updateImageFile(compressedImage);
        controller.updateImageUrl("");
      } else {
        controller.updateImageFile(File(entity.fileName));
        controller.updateImageUrl("");
      }
      controller.changeIsLoading(true);
      offlineEffect.clear();
      controller.changeIsPhotoSelect(true);
      controller.changeIsPhotoDone(false);
      // getCartoon(context);
      return true;
    } on PlatformException catch (error) {
      if (error.code == "photo_access_denied") {
        showPhotoLibraryPermissionDialog(context);
      }
    } catch (error) {
      CommonExtension().showToast("Try to select valid image");
    }
    return false;
  }

  Future<void> pickFromRecent(BuildContext context) async {
    PickPhotoScreen.push(
      context,
      selectedFile: controller.image.value,
      controller: uploadImageController,
      floatWidget: _createEffectModelIcon(
        context,
        effectItem: tabItemList[currentItemIndex.value].data,
        checked: true,
      ),
      onPickFromSystem: (takePhoto) async {
        if (takePhoto) {
          return await pickImageFromCamera(context, from: "result");
        } else {
          return await pickImageFromGallery(context, from: "result");
        }
      },
      onPickFromRecent: (entity) async {
        return await pickImageFromGallery(context, from: "result", entity: entity);
      },
      onPickFromAiSource: (file) async {
        return await pickImageFromGallery(context, from: "result", file: file);
      },
    );
  }
  Future<void> saveToAlbum() async {
    // var imageData = (await SyncFileImage(file: File(image)).getImage()).image;
    // if (lastBuildType == _BuildType.waterMark) {
    //   var assetImage = AssetImage(Images.ic_watermark).resolve(ImageConfiguration.empty);
    //   assetImage.addListener(ImageStreamListener((image, synchronousCall) async {
    //     ui.Image? cropImage;
    //     if ((controller.cropImage.value != null && includeOriginalFace())) {
    //       if (cropKey.currentContext != null) {
    //         cropImage = await getBitmapFromContext(cropKey.currentContext!);
    //       }
    //     }
    //     var uint8list = await addWaterMark(image: imageData, watermark: image.image, originalImage: cropImage);
    //     String imgDir = AppDelegate.instance.getManager<CacheManager>().storageOperator.tempDir.path;
    //     var file = File(imgDir + "${DateTime.now().millisecondsSinceEpoch}.png");
    //     await file.writeAsBytes(uint8list.toList());
    //     await GallerySaver.saveImage(file.path, albumName: saveAlbumName);
    //     CommonExtension().showImageSavedOkToast(context);
    //   }));
    // } else {
    //   ui.Image? cropImage;
    //   if ((controller.cropImage.value != null && includeOriginalFace())) {
    //     if (cropKey.currentContext != null) {
    //       cropImage = await getBitmapFromContext(cropKey.currentContext!);
    //     }
    //   }
    //   var uint8list = await addWaterMark(image: imageData, originalImage: cropImage);
    //   String imgDir = AppDelegate.instance.getManager<CacheManager>().storageOperator.tempDir.path;
    //   var file = File(imgDir + "${DateTime.now().millisecondsSinceEpoch}.png");
    //   await file.writeAsBytes(uint8list.toList());
    //   await GallerySaver.saveImage(file.path, albumName: saveAlbumName);
    //   CommonExtension().showImageSavedOkToast(context);
    // }

    // delay(() => userManager.rateNoticeOperator.onSwitch(context), milliseconds: 2000);
  }

  showSavePhotoDialog(BuildContext context) {
    saveToAlbum();
  }


  Widget _buildInOutControlPad() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(Images.ic_camera, height: $(24), width: $(24))
            .intoGestureDetector(
          // onTap: () => showPickPhotoDialog(context),
          onTap: (){
            // pickFromRecent(context);
            // pickImageFromGallery(context, from: "result");
            _setURL();
          },
        ).intoContainer(margin: EdgeInsets.symmetric(horizontal: $(15))),
        SizedBox(width: 50),
        Image.asset(Images.ic_download, height: $(24), width: $(24))
            .intoGestureDetector(
          onTap: (){
            showSavePhotoDialog(context);
          },
        ).intoContainer(margin: EdgeInsets.symmetric(horizontal: $(15))),
        SizedBox(width: 50),
        Image.asset(Images.ic_share_discovery, height: $(24), width: $(24))
            .intoGestureDetector(
          onTap: () {
            // shareToDiscovery();
          },
        ).intoContainer(margin: EdgeInsets.symmetric(horizontal: $(15)))
      ],
    )
        .intoContainer(
      margin: EdgeInsets.only(top: $(10), left: $(23), right: $(23), bottom: $(10)),
    );
  }
  Widget _buildImageView() {
    return Expanded(child:Container(
      margin: EdgeInsets.only(top: 5),
      child: _byte != null
          ?Image.memory(
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
        child: Image.asset(Images.ic_choose_photo_initial_header),
      ),
    ),);
    // return Expanded(child: Column(
    //   mainAxisAlignment: MainAxisAlignment.center,
    //   children: [Image.asset(Images.ic_choose_photo_initial_header)],
    // ),);
  }
  Widget _buildEffectController(){
    return ScrollablePositionedList.separated(
      initialScrollIndex: 0,
      itemCount: 10,
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        return GestureDetector(
            onTap: () {
              setState(() {
                selectedEffectID = index;
              });
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 65,
                  height: 65,
                  decoration: (selectedEffectID == index)?
                  BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Color(0xFF05E0D5),
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                  )
                  : null
                  ,
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      margin: EdgeInsets.all(2.0),
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(Images.ic_choose_photo_initial_header),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                Text('Text',style: TextStyle(
                  color: Colors.white,
                ),),
                SizedBox(height: 2),
            ],
          )
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return Container();
      },
    ).intoContainer(
      height: itemWidth + $(40),
    );
  }
  Widget _buildFiltersController(){
    return ScrollablePositionedList.separated(
      initialScrollIndex: 0,
      itemCount: filters.length,
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        return GestureDetector(
            onTap: () {
              setState(() {
                selectedFilterID = index;
                _Filter(filters[index]);
              });
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 65,
                  height: 65,
                  decoration: (selectedFilterID == index)?
                  BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Color(0xFF05E0D5),
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                  )
                      : null
                  ,
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      margin: EdgeInsets.all(2.0),
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(Images.ic_choose_photo_initial_header),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                Text(filters[index],style: TextStyle(
                  color: Colors.white,
                ),),
                SizedBox(height: 2),
              ],
            )
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return Container();
      },
    ).intoContainer(
      height: itemWidth + $(40),
    );
  }
  Widget _buildAdjust() {
    double _currentSliderValue = 0;
    List<Widget> buttons = [];
    for (int i = 0; i < 3; i++){
      int cur_i  = i;
      buttons.add(GestureDetector(
        onTap: () {
          setState(() {
            currentAdjustID = cur_i;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: (currentAdjustID == cur_i)?
            Border.all(color: const Color(0xFF05E0D5), width: 2)
            :Border.all(color: Colors.white, width: 2),
          ),
          child: CircleAvatar(
            backgroundImage: AssetImage(Images.ic_adjust),
            radius: 25.0,
            backgroundColor: Colors.transparent,
          ),
        ),
      ));
      buttons.add(SizedBox(width: 20));
    }

    return Container(
        height: itemWidth + $(40),
        child:Column(
          children:[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: buttons,
            ),
            GridSlider(minVal: 0, maxVal: 100, currentPos: 50)
          ]
        )
    );
  }
  Widget _buildCrops() {
    List<Widget> buttons = [];
    List<List<int>> ratios = [[2, 3, 20, 30], [3,2,30,20], [3,4,22,30],[4,3,30,22],[1,1,30,30]];
    int i = 0;
    for(List<int> ratio in ratios){
      int curi = i;
      buttons.add(
          GestureDetector(
            onTap: () {
              selectedRightTab = curi;
            },
            child: Column(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  child: Center(
                    child: Container(
                      width: ratio.elementAt(2).toDouble(),
                      height: ratio.elementAt(3).toDouble(),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(width: 2.0, color: Colors.white),
                          left: BorderSide(width: 2.0, color: Colors.white),
                          right: BorderSide(width: 2.0, color: Colors.white),
                          bottom: BorderSide(width: 2.0, color: Colors.white),
                        ),
                      ),
                    ),
                  )
                ),
                SizedBox(height: 10,),
                Text(
                  ratio.elementAt(0).toString() + ":" + ratio.elementAt(1).toString(),
                  style: TextStyle(
                      color: Colors.white
                  ),
                )
              ],
            ),
          )
      );
      buttons.add(SizedBox(width: 30,));
      i++;
    }
    return Container(
      height: itemWidth + $(40),
      child:Center(
        child:Row(
          mainAxisSize: MainAxisSize.min,
          children: buttons,
        )
      )
    );
  }
  Widget _buildBackground() {
    return ScrollablePositionedList.separated(
      initialScrollIndex: 0,
      itemCount: 10,
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        return GestureDetector(
            onTap: () {
              setState(() {
                selectedFilterID = index;
              });
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 65,
                  height: 65,
                  decoration: (selectedFilterID == index)?
                  BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Color(0xFF05E0D5),
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                  )
                      : null
                  ,
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      margin: EdgeInsets.all(2.0),
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(Images.ic_choose_photo_initial_header),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 40),
              ],
            )
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return Container();
      },
    ).intoContainer(
      height: itemWidth + $(40),
    );

  }
  Widget _buildBottomTabbar() {
    switch(selectedRightTab) {
      case 0:
        return _buildEffectController();
      case 1:
        return _buildFiltersController();
      case 2:
        return _buildAdjust();
      case 3:
        return _buildCrops();
      case 4:
        return _buildBackground();
      default:
        return Container(height: itemWidth + $(10));
    }
  }
  @override
  Widget build(BuildContext context) {
    var content = LoadingOverlay(
          isLoading: isLoading,
          child: Stack(
              children: <Widget>[
                Scaffold(
                  backgroundColor: ColorConstant.BackgroundColor,
                  appBar: AppNavigationBar(
                    backAction: () async {
                      // if (await _willPopCallback(context)) {
                      Navigator.of(context).pop();
                      // }
                    },
                    backgroundColor: ColorConstant.BackgroundColor,
                    trailing: Image.asset(
                      Images.ic_share,
                      width: $(24),
                    ).intoGestureDetector(onTap: () async {
                      // shareOut();
                    }),
                  ),
                  body: Column(
                    children: [
                      _buildImageView(),
                      _buildInOutControlPad(),
                      SizedBox(height: $(8)),
                      _buildBottomTabbar(),
                      SizedBox(height: MediaQuery.of(context).padding.bottom)
                    ],
                  ),
                ).ignore(ignoring: isLoading),
                _buildRightTab()
              ]));
      return content;
  }

}
