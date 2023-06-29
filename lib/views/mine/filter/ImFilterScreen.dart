
import 'dart:io';

import 'package:cartoonizer/Common/Extension.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Controller/ChoosePhotoScreenController.dart';
import 'package:cartoonizer/Controller/effect_data_controller.dart';
import 'package:cartoonizer/Controller/upload_image_controller.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/cacheImage/cached_network_image_utils.dart';
import 'package:cartoonizer/Widgets/progress/circle_progress_bar.dart';
import 'package:cartoonizer/Widgets/video/effect_video_player.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/models/OfflineEffectModel.dart';
import 'package:cartoonizer/models/api_config_entity.dart';
import 'package:cartoonizer/models/upload_record_entity.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:cartoonizer/views/mine/filter/Adjust.dart';
import 'package:cartoonizer/views/mine/filter/Filter.dart';
import 'package:cartoonizer/views/mine/filter/FilterCropScreen.dart';
import 'package:cartoonizer/views/mine/filter/GridSlider.dart';
import 'package:cartoonizer/views/mine/filter/ImCropScreen.dart';
import 'package:cartoonizer/views/mine/filter/ImCropper.dart';
import 'package:cartoonizer/views/transfer/pick_photo_screen.dart';
import 'package:cropperx/cropperx.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as imgLib;
import 'package:cartoonizer/Widgets/progress/circle_progress_bar.dart';

import 'Crop.dart';



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
  Uint8List? _byte;
  final picker = ImagePicker();
  final GlobalKey _cropperKey = GlobalKey(debugLabel: 'cropperKey');

  // List<ChooseTabItemInfo> tabItemList = [];
  late ItemScrollController itemScrollController;
  final ItemPositionsListener itemScrollPositionsListener = ItemPositionsListener.create();
  late double itemWidth;
  var currentItemIndex = 0.obs;
  List<String> _rightTabList = [Images.ic_effect, Images.ic_filter, Images.ic_adjust,Images.ic_crop, Images.ic_background, Images.ic_letter];
  int selectedRightTab = 0;

  int selectedEffectID = 0;
  Filter filter = new Filter();
  Adjust adjust = new Adjust();
  Crop crop = new Crop();
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
    if(pickedFile!=null) {
      _imagefile = File(pickedFile!.path);
      _image = await getLibImage(await getImage(_imagefile!));
      _byte = Uint8List.fromList(imgLib.encodeJpg(_image));

      setState(() {
        _imagefile;
      });
    }
  }


  _Filter(String filterStr) async {
    if (_imagefile != null) {
      _byte = Uint8List.fromList(imgLib.encodeJpg(await Filter.ImFilter(filterStr,_image)));
      setState(() {
        _byte;
      });
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
          // if(cur == 3) {
          //   Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //       settings: RouteSettings(name: "/CropperScreen"),
          //       builder: (context) =>
          //           CropperScreen(),
          //     ),
          //   ).then((value) {
          //
          //   });
          // } else{
            setState(() {
              selectedRightTab = cur;
            });
          // }
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
          ? (selectedRightTab ==3)
      ?Container(
        color: Colors.black,
        constraints: BoxConstraints(
          maxHeight: 800.0, // Set the maximum height
        ),
        child: Center(
          child: Cropper(
            cropperKey: _cropperKey,
            overlayType: OverlayType.grid,
            rotationTurns: 0,
            aspectRatio: crop.aspectRatio,
            image: Image.memory(_byte!),
            onScaleStart: (details) {
              // todo: define started action.
            },
            onScaleUpdate: (details) {
              // todo: define updated action.
            },
            onScaleEnd: (details) {
              // todo: define ended action.
            },
          ),
        ),
      )
      :Image.memory(
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
      itemCount: Filter.filters.length,
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        return GestureDetector(
            onTap: () {
              setState(() {
                filter.setSelectedID(index);
                _Filter(Filter.filters[index]);
              });
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 65,
                  height: 65,
                  decoration: (filter.getSelectedID() == index)?
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
                Text(Filter.filters[index],style: TextStyle(
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
    final ScrollController _scrollController = ScrollController();
    List<Widget> buttons = [];
    buttons.add(SizedBox(width: MediaQuery.of(context).size.width / 2));
    for (int i = 0; i < adjust.getCnt(); i++){
      int cur_i  = i;
      buttons.add(GestureDetector(
        onTap: ()  async {
          if(adjust.getSelectedID() == cur_i && !adjust.isInitalized) {
            adjust.previousValue = adjust.getSelectedValue();
            adjust.setSliderValue(adjust.initSliderValues[cur_i]);
            adjust.isInitalized = true;
            setState((){
              adjust;
            });
            if (_imagefile != null) {
              _byte = Uint8List.fromList(imgLib.encodeJpg(await adjust.ImAdjust(_image)));
              setState(() {
              });
            }
          }
          else if(adjust.getSelectedID() == cur_i && adjust.isInitalized) {
            adjust.setSliderValue(adjust.previousValue);
            adjust.isInitalized = false;
            setState((){
              adjust;
            });
            if (_imagefile != null) {
              _byte = Uint8List.fromList(imgLib.encodeJpg(await adjust.ImAdjust(_image)));
              setState(() {
                _byte;
              });
            }

          }
          else{
            setState(() {
              adjust.setSelectedID(cur_i);
            });
          }
          _scrollController.animateTo(
            25 + 74.0 * cur_i,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        },
        child: (adjust.getSelectedID() != cur_i)?
        Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: (adjust.getSelectedID() == cur_i)?
                Border.all(color: const Color(0xFF05E0D5), width: 2)
                    :Border.all(color: Colors.grey, width: 2),
              ),
              child: CircleAvatar(
                radius: 20.0,
                backgroundColor: Colors.transparent,
              ),
            ),
            Positioned.fill(
              child: Align(
                alignment: Alignment.center,
                child: Image.asset(Adjust.assets[cur_i], width: 25, height: 25),
              ),
            ),
          ]
        )

        : Stack(
          children: [
            (adjust.getSelectedValue() >= 0)?
            AppCircleProgressBar(
              size: 42,
              ringWidth: 2,
              backgroundColor: Colors.grey,
              progress: adjust.getSelectedValue()/(adjust.range[adjust.selectedID][1]),
              loadingColors: [
                Color(0xFF05E0D5),
                Color(0xFF05E0D5),
                Color(0xFF05E0D5),
                Color(0xFF05E0D5),
                Color(0xFF05E0D5),
              ],
            )
            :AppCircleProgressBar(
            size: 42,
            ringWidth: 2,
            backgroundColor: Colors.white,
            progress: 1 - adjust.getSelectedValue()/ adjust.range[adjust.selectedID][0],
            loadingColors: [
              Colors.grey,
              Colors.grey,
              Colors.grey,
              Colors.grey,
              Colors.grey,
            ],
          ),
            Container(
              width: 42,
              height: 42,// Sets maximum width of container to screen width
              alignment: Alignment.center, // Centers contents horizontally and vertically
              child: Text(
                adjust.getSliderValue(cur_i).toInt().toString(),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            )
          ],
        )

      ));
      buttons.add(SizedBox(width: 30));
    }
    buttons.add(SizedBox(width: MediaQuery.of(context).size.width / 2));

    return Container(
        height: itemWidth + $(40),
        child:Column(
          children:[
            Text(
              Adjust.filters[adjust.selectedID],
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 5),
            SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                child: Row(
                  // mainAxisAlignment: MainAxisAlignment.end,
                  children: buttons,
                ),
              ),
            SizedBox(height: 3),
            GridSlider(minVal: adjust.range[adjust.selectedID][0], maxVal: adjust.range[adjust.selectedID][1], currentPos: adjust.getSelectedValue(),
              onChanged: (newValue){
                adjust.setSliderValue(newValue);
                adjust.isInitalized = false;
                setState(() {
                  adjust;
                });
              }, onEnd: () async {
                if (_imagefile != null) {
                  _byte = Uint8List.fromList(imgLib.encodeJpg(await adjust.ImAdjust(_image)));
                  setState(() {
                    _byte;
                  });
                }
              })
          ]
        )
    );
  }
  Widget _buildCrops() {
    List<Widget> buttons = [];
    int i = 0;
    for(List<int> ratio in crop.ratios){
      int curi = i;
      buttons.add(
          GestureDetector(
            onTap: () {
              setState(() {
                crop.selectedID = curi;
                crop.aspectRatio = crop.ratios[curi][0] / crop.ratios[curi][1];
              });
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
                          top: BorderSide(width: 2.0, color: (crop.selectedID == curi)? Color(0xFF05E0D5): Colors.white),
                          left: BorderSide(width: 2.0, color: (crop.selectedID == curi)? Color(0xFF05E0D5): Colors.white),
                          right: BorderSide(width: 2.0, color: (crop.selectedID == curi)? Color(0xFF05E0D5): Colors.white),
                          bottom: BorderSide(width: 2.0, color: (crop.selectedID == curi)? Color(0xFF05E0D5): Colors.white),
                        ),
                      ),
                    ),
                  )
                ),
                SizedBox(height: 10,),
                Text(
                  ratio.elementAt(0).toString() + ":" + ratio.elementAt(1).toString(),
                  style: TextStyle(
                      color: (crop.selectedID == curi)? Color(0xFF05E0D5): Colors.white
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
                filter.setSelectedID(index);
              });
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 65,
                  height: 65,
                  decoration: (filter.getSelectedID() == index)?
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