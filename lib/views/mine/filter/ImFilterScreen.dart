import 'dart:io';

import 'package:cartoonizer/Common/Extension.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Controller/effect_data_controller.dart';
import 'package:cartoonizer/Controller/upload_image_controller.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/camera/pai_camera_screen.dart';
import 'package:cartoonizer/Widgets/progress/circle_progress_bar.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/api/filter_api.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:cartoonizer/views/ai/anotherme/anotherme.dart';
import 'package:cartoonizer/views/common/background/background_picker.dart';
import 'package:cartoonizer/views/mine/filter/Adjust.dart';
import 'package:cartoonizer/views/mine/filter/BackgroundRemoval.dart';
import 'package:cartoonizer/views/mine/filter/DecorationCropper.dart';
import 'package:cartoonizer/views/mine/filter/Filter.dart';
import 'package:cartoonizer/views/mine/filter/GridSlider.dart';
import 'package:common_utils/common_utils.dart';
import 'package:cropperx/cropperx.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image/image.dart' as imgLib;
import 'dart:ui' as ui;

import 'Crop.dart';
import 'ImageMergingWidget.dart';

enum TABS{
  EFFECT,
  FILTER,
  ADJUST,
  CROP,
  BACKGROUND,
  TEXT
}

class ImFilterScreen extends StatefulWidget {
  ImFilterScreen({Key? key}) : super(key: key);

  @override
  _ImFilterScreenState createState() => _ImFilterScreenState();
}

class _ImFilterScreenState extends AppState<ImFilterScreen> with SingleTickerProviderStateMixin {

  File? _imageFile, _personImageFile;
  late imgLib.Image _image, _personImage, _backgroundImage, _addedImage;
  late ui.Image _personImageForUi;
  bool _isPersonImageInitialized = false, _isBackgroundImageInitialized = false;
  Uint8List? _byte;
  final GlobalKey _cropperKey = GlobalKey(debugLabel: 'cropperKey');
  GlobalKey _ImageViewerBackgroundKey = GlobalKey();
  bool originalShowing = false;

  late double itemWidth;
  var currentItemIndex = 0.obs;
  List<String> _rightTabList = [Images.ic_effect, Images.ic_filter, Images.ic_adjust, Images.ic_crop, Images.ic_background]; //, Images.ic_letter];
  late TABS selectedRightTab = TABS.EFFECT;

  int selectedEffectID = 0;
  Filter filter = new Filter();
  Adjust adjust = new Adjust();
  Crop crop = new Crop();
  BackgroundRemoval backgroundRemoval = new BackgroundRemoval();

  int currentAdjustID = 0;

  int selectedCropID = 0;
  var processedImageURL = null;

  UploadImageController uploadImageController = Get.put(UploadImageController());

  @override
  void initState() {
    super.initState();
    itemWidth = (ScreenUtil.screenSize.width - $(90)) / 5;
  }

  @override
  void dispose() {
    super.dispose();
  }
  Future<ui.Image> convertImage(imgLib.Image image) async {
    List<int> pngBytes = imgLib.encodePng(image);
    Uint8List uint8List = Uint8List.fromList(pngBytes);
    ui.Codec codec = await ui.instantiateImageCodec(uint8List);
    ui.FrameInfo frameInfo = await codec.getNextFrame();
    return frameInfo.image;
  }
  pickImage() {
    showLoading().whenComplete(() {
      AnotherMe.checkPermissions().then((value) {
        if (value) {
          PAICamera.takePhoto(context).then((value) async {
            if (value != null) {
              var pickFile = File(value.xFile.path);
              _imageFile = File(pickFile.path);
              _image = await getLibImage(await getImage(_imageFile!));
              _byte = Uint8List.fromList(imgLib.encodeJpg(_image));
              await filter.calcAvatars(_image);

              try {
                ///background removal calculation
                File compressedImage = await imageCompressAndGetFile(_imageFile!, imageSize: Get.find<EffectDataController>().data?.imageMaxl ?? 512);
                await uploadImageController.uploadCompressedImage(compressedImage);
                uploadImageController.update();
                var url = await FilterApi().removeBgAndSave(imageUrl: uploadImageController.imageUrl.value);
                _personImageFile = File(url!);
                _personImage = await getLibImage(await getImage(_personImageFile!));
                _personImageForUi = await convertImage(_personImage);
                _isPersonImageInitialized = true;
                // _byte = Uint8List.fromList(imgLib.encodeJpg(_personImage));
              } catch (e) {
                print('An exception occurred: $e');
              }
              hideLoading();
              setState(() {
                _byte;
                _imageFile;
                _isPersonImageInitialized;
              });
            } else {
              hideLoading();
            }
          });
        } else {
          hideLoading().whenComplete(() {
            AnotherMe.permissionDenied(context);
          });
        }
      });
    });
  }

  _Filter(String filterStr) async {
    if (_imageFile != null) {
      _byte = Uint8List.fromList(imgLib.encodeJpg(await Filter.ImFilter(filterStr, _image)));
      setState(() {
        _byte;
      });
    }
  }

  Widget _buildRightTab() {
    List<Widget> buttons = [];
    int num = 0;
    for (var img in _rightTabList) {
      int cur = num;
      buttons.add(GestureDetector(
        onTap: () {
          setState(() {
            selectedRightTab = TABS.values[cur];
          });
        },
        child: Container(
          width: $(40),
          height: $(40),
          decoration: (selectedRightTab == TABS.values[cur])
              ? BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [const Color(0xFF68F0AF), const Color(0xFF05E0D5)],
                  ),
                  borderRadius: BorderRadius.circular($(20)),
                )
              : BoxDecoration(
                  borderRadius: BorderRadius.circular($(20)),
                ),
          child: FractionallySizedBox(
            widthFactor: 0.6,
            heightFactor: 0.6,
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
      onTapDown: (TapDownDetails details) {
        setState(() {
          originalShowing = true;
        });
      },
      onTapUp: (TapUpDetails details) {
        setState(() {
          originalShowing = false;
        });
      },
      onTapCancel: () {
        setState(() {
          originalShowing = false;
        });
      },
      child: Container(
              width: $(40),
              height: $(40),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular($(20)),
              ),
              child: FractionallySizedBox(
                widthFactor: 0.6,
                heightFactor: 0.6,
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
        child: Container(
            height: $(350),
            width: $(50),
            margin: EdgeInsets.only(right: $(10)),
            child: Column(children: [
              Container(
                  decoration: BoxDecoration(color: Color.fromARGB(100, 22, 44, 33), borderRadius: BorderRadius.all(Radius.circular($(50)))),
                  padding: EdgeInsets.symmetric(horizontal: $(5), vertical: $(10)),
                  height: $(220),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: buttons)
              ),
              SizedBox(height:$(50)),
              (selectedRightTab != TABS.CROP)
              ?Container(
                  decoration: BoxDecoration(color: Color.fromARGB(100, 22, 44, 33), borderRadius: BorderRadius.all(Radius.circular($(50)))),
                  height: $(42),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: adjustbutton)
              )
                  :Container()
            ])
        )
    );
  }

  Future<void> saveToAlbum() async {
    if (_byte == null) return;
    String imgDir = AppDelegate.instance.getManager<CacheManager>().storageOperator.tempDir.path;
    var file = File(imgDir + "${DateTime.now().millisecondsSinceEpoch}.png");
    if(selectedRightTab == TABS.CROP && crop.selectedID > 0) {
      Uint8List? _croppedByte = await Cropper.crop(
        cropperKey: _cropperKey,
      );
      await file.writeAsBytes(_croppedByte!);
    }
    else{
      await file.writeAsBytes(_byte!);
    }
    await GallerySaver.saveImage(file.path, albumName: "PandoraAI");
    CommonExtension().showImageSavedOkToast(context);
  }

  Widget _buildInOutControlPad() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(Images.ic_camera, height: $(24), width: $(24)).intoGestureDetector(
          onTap: () {
            pickImage();
          },
        ).intoContainer(margin: EdgeInsets.symmetric(horizontal: $(15))),
        SizedBox(width: $(50)),
        Image.asset(Images.ic_download, height: $(24), width: $(24)).intoGestureDetector(
          onTap: () {
            saveToAlbum();
          },
        ).intoContainer(margin: EdgeInsets.symmetric(horizontal: $(15))),
        SizedBox(width: $(50)),
        Image.asset(Images.ic_share_discovery, height: $(24), width: $(24)).intoGestureDetector(
          onTap: () {
            // shareToDiscovery();
          },
        ).intoContainer(margin: EdgeInsets.symmetric(horizontal: $(15)))
      ],
    ).intoContainer(
      margin: EdgeInsets.only(top: $(10), left: $(23), right: $(23), bottom: $(2)),
    );
  }

  Widget _buildImageView() {
    return Expanded(
      child: Stack(children: <Widget>[
        Container(key:_ImageViewerBackgroundKey),
        Column(
          children: [
            Expanded(
                child: Row(
                  children: [
                      Expanded(
                          child: Container(
                            margin: EdgeInsets.only(top: $(5)),
                            child: _byte != null
                                ? originalShowing
                                  ? Container(
                                    child: Image.file(_imageFile!, fit: BoxFit.contain),
                                  )
                                  : (selectedRightTab == TABS.CROP && crop.selectedID > 0)
                                  ? Container(color: Colors.black, child: Center(child: DecorationCropper(cropperKey: _cropperKey, crop: crop, byte: _byte, globalKey: _ImageViewerBackgroundKey,)))
                                  : (selectedRightTab== TABS.BACKGROUND && _isPersonImageInitialized && _isBackgroundImageInitialized)
                                  ?ImageMergingWidget(personImage: _personImage, personImageForUI: _personImageForUi, backgroundImage: _backgroundImage,
                                    onAddImage: (image){
                                      _isBackgroundImageInitialized = false;
                                      _addedImage = image;
                                      _byte = Uint8List.fromList(imgLib.encodeJpg(_addedImage));
                                      setState(() {
                                        _byte;
                                      });
                                    },)
                                  :Image.memory(
                                    _byte!,
                                    fit: BoxFit.contain,
                                  )
                                  : Container(
                                child: Image.asset(Images.ic_choose_photo_initial_header),
                                ),
                          )
                      )
                    ],
                  ))
          ],
        ),
        _buildRightTab()
      ]
    ),
    );
  }

  Widget _buildEffectController() {
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
                  width: $(65),
                  height: $(65),
                  decoration: (selectedEffectID == index)
                      ? BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Color(0xFF05E0D5),
                            width: 2,
                            style: BorderStyle.solid,
                          ),
                        )
                      : null,
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      margin: EdgeInsets.all(2.0),
                      width: $(60),
                      height: $(60),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(Images.ic_choose_photo_initial_header),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                Text(
                  'Text',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: $(2)),
              ],
            ));
      },
      separatorBuilder: (BuildContext context, int index) {
        return Container();
      },
    ).intoContainer(
      height: $(115),
    );
  }

  Widget _buildFiltersController() {
    return ScrollablePositionedList.separated(
      initialScrollIndex: 0,
      itemCount: filter.avatars.length,
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
                  width: $(65),
                  height: $(65),
                  decoration: (filter.getSelectedID() == index)
                      ? BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Color(0xFF05E0D5),
                            width: 2,
                            style: BorderStyle.solid,
                          ),
                        )
                      : null,
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                        margin: EdgeInsets.all(2.0),
                        child: Image.memory(
                          filter.avatars[index],
                          fit: BoxFit.cover,
                        )),
                  ),
                ),
                Text(
                  Filter.filters[index],
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: $(2)),
              ],
            ));
      },
      separatorBuilder: (BuildContext context, int index) {
        return Container();
      },
    ).intoContainer(
      height: $(115),
    );
  }

  Widget _buildAdjust() {
    final ScrollController _scrollController = ScrollController();
    List<Widget> buttons = [];
    buttons.add(SizedBox(width: MediaQuery.of(context).size.width / 2 - ($(45) / 2)));
    for (int i = 0; i < adjust.getCnt(); i++) {
      int cur_i = i;
      buttons.add(GestureDetector(
          onTap: () async {
            if (adjust.getSelectedID() == cur_i && !adjust.isInitalized) {
              adjust.previousValue = adjust.getSelectedValue();
              adjust.setSliderValue(adjust.initSliderValues[cur_i]);
              adjust.isInitalized = true;
              setState(() {
                adjust;
              });
              if (_imageFile != null) {
                _byte = Uint8List.fromList(imgLib.encodeJpg(await adjust.ImAdjust(_image)));
                setState(() {});
              }
            } else if (adjust.getSelectedID() == cur_i && adjust.isInitalized) {
              adjust.setSliderValue(adjust.previousValue);
              adjust.isInitalized = false;
              setState(() {
                adjust;
              });
              if (_imageFile != null) {
                _byte = Uint8List.fromList(imgLib.encodeJpg(await adjust.ImAdjust(_image)));
                setState(() {
                  _byte;
                });
              }
            } else {
              setState(() {
                adjust.setSelectedID(cur_i);
              });
            }
            _scrollController.animateTo(
              $(74) * cur_i,
              duration: Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          },
          child: (adjust.getSelectedID() != cur_i)
              ? Stack(children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: (adjust.getSelectedID() == cur_i) ? Border.all(color: const Color(0xFF05E0D5), width: $(2)) : Border.all(color: Colors.grey, width: $(2)),
                    ),
                    child: CircleAvatar(
                      radius: $(20),
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.center,
                      child: Image.asset(Adjust.assets[cur_i], width: $(25), height: $(25)),
                    ),
                  ),
                ])
              : Stack(
                  children: [
                    (adjust.getSelectedValue() >= 0)
                        ? AppCircleProgressBar(
                            size: $(45),
                            ringWidth: $(2),
                            backgroundColor: Colors.grey,
                            progress: adjust.getSelectedValue() / (adjust.range[adjust.selectedID][1]),
                            loadingColors: [
                              Color(0xFF05E0D5),
                              Color(0xFF05E0D5),
                              Color(0xFF05E0D5),
                              Color(0xFF05E0D5),
                              Color(0xFF05E0D5),
                            ],
                          )
                        : AppCircleProgressBar(
                            size: $(45),
                            ringWidth: $(2),
                            backgroundColor: Colors.white,
                            progress: 1 - adjust.getSelectedValue() / adjust.range[adjust.selectedID][0],
                            loadingColors: [
                              Colors.grey,
                              Colors.grey,
                              Colors.grey,
                              Colors.grey,
                              Colors.grey,
                            ],
                          ),
                    Container(
                      width: $(45),
                      height: $(45), // Sets maximum width of container to screen width
                      alignment: Alignment.center, // Centers contents horizontally and vertically
                      child: Text(
                        adjust.getSliderValue(cur_i).toInt().toString(),
                        style: TextStyle(
                          fontSize: $(14),
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  ],
                )));
      buttons.add(SizedBox(width: $(30)));
    }
    buttons.add(SizedBox(width: MediaQuery.of(context).size.width / 2 - $(45)));

    return Container(
        height: $(115),
        child: Column(children: [
          Text(
            Adjust.filters[adjust.selectedID],
            style: TextStyle(
              fontSize: $(10),
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: $(5)),
          SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            child: Row(
              // mainAxisAlignment: MainAxisAlignment.end,
              children: buttons,
            ),
          ),
          SizedBox(height: $(3)),
          GridSlider(
              minVal: adjust.range[adjust.selectedID][0],
              maxVal: adjust.range[adjust.selectedID][1],
              currentPos: adjust.getSelectedValue(),
              onChanged: (newValue) {
                adjust.setSliderValue(newValue);
                adjust.isInitalized = false;
                setState(() {
                  adjust;
                });
              },
              onEnd: () async {
                if (_imageFile != null) {
                  _byte = Uint8List.fromList(imgLib.encodeJpg(await adjust.ImAdjust(_image)));
                  setState(() {
                    _byte;
                  });
                }
              })
        ]));
  }

  Widget _buildCrops() {
    List<Widget> buttons = [];
    int i = 0;
    for (String title in crop.titles[crop.isPortrait]) {
      int curi = i;
      buttons.add(GestureDetector(
        onTap: () {
          setState(() {
            crop.selectedID = curi;
            crop.isPortrait = crop.isPortrait;
            // crop.aspectRatio = crop.ratios[curi][0] / crop.ratios[curi][1];
          });
        },
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(color: (crop.selectedID == curi) ? Color(0xFF05E0D5) : Colors.white),
            )
          ],
        ),
      ));
      buttons.add(SizedBox(
        width: $(30),
      ));
      i++;
    }
    return Container(
        height: $(115),
        child: Center(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            (crop.selectedID >= 2)
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () {
                          // Handle button press
                          setState(() {
                            crop.isPortrait = 0;
                          });
                          print('Button pressed!');
                        },
                        child: Container(
                          child: (crop.isPortrait == 0) ? Image.asset(Images.ic_landscape_selected) : Image.asset(Images.ic_landscape), // Replace with your image path
                        ),
                      ),
                      SizedBox(width: $(30)),
                      InkWell(
                        onTap: () {
                          // Handle button press
                          setState(() {
                            crop.isPortrait = 1;
                          });
                          print('Button pressed!');
                        },
                        child: Container(
                          child: (crop.isPortrait == 1) ? Image.asset(Images.ic_portrat_selected) : Image.asset(Images.ic_portrat), // Replace with your image path
                        ),
                      )
                    ],
                  )
                : SizedBox(
                    height: $(32),
                  ),
            SizedBox(
              height: $(30),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: buttons,
            )
          ],
        )));
  }

  Widget _buildBackground() {
    return BackgroundPickerBar(
      imageRatio: 16 / 9,
      onPick: (BackgroundData data) async {
        // _backgroundImage = await backgroundRemoval.addBackgroundImage(_personImage, data.filePath!);
        File backFile = File(data.filePath!);
        _backgroundImage = await getLibImage(await getImage(backFile));
        _isBackgroundImageInitialized = true;
        setState(() {
          _isBackgroundImageInitialized;
        });
      },
    ).intoContainer(
      width: double.maxFinite,
      padding: EdgeInsets.symmetric(horizontal: $(4)),
      height: $(115),
    );
  }

  Widget _buildBottomTabbar() {
    switch (selectedRightTab) {
      case TABS.EFFECT:
        return _buildEffectController();
      case TABS.FILTER:
        return _buildFiltersController();
      case TABS.ADJUST:
        return _buildAdjust();
      case TABS.CROP:
        return _buildCrops();
      case TABS.BACKGROUND:
        return _buildBackground();
      default:
        return Container(height: $(115));
    }
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
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
            // SizedBox(height: ScreenUtil.getBottomPadding(context)),
          ],
        ),
      );
  }
}
