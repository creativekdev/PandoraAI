import 'dart:convert';
import 'dart:io';

import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/background_card.dart';
import 'package:cartoonizer/Widgets/outline_widget.dart';
import 'package:cartoonizer/Widgets/progress/circle_progress_bar.dart';
import 'package:cartoonizer/Widgets/router/routers.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/Widgets/tabbar/app_tab_bar.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:cartoonizer/views/common/background/background_picker.dart';
import 'package:cartoonizer/views/mine/filter/Adjust.dart';
import 'package:cartoonizer/views/mine/filter/DecorationCropper.dart';
import 'package:cartoonizer/views/mine/filter/Filter.dart';
import 'package:cartoonizer/views/mine/filter/GridSlider.dart';
import 'package:cartoonizer/views/mine/filter/im_filter_controller.dart';
import 'package:cartoonizer/views/mine/filter/im_pin_view.dart';
import 'package:cartoonizer/views/mine/filter/im_remove_bg_screen.dart';
import 'package:image/image.dart' as imgLib;

import '../../../app/app.dart';
import '../../../app/thirdpart/thirdpart_manager.dart';
import '../../../app/user/user_manager.dart';
import '../../ai/anotherme/widgets/li_pop_menu.dart';
import '../../share/ShareScreen.dart';
import 'im_filter.dart';

class ImFilterScreen extends StatefulWidget {
  String filePath;
  TABS tab;
  final OnCallback? onCallback;

  ImFilterScreen({
    Key? key,
    required this.filePath,
    this.tab = TABS.EFFECT,
    this.onCallback,
  }) : super(key: key);

  @override
  _ImFilterScreenState createState() => _ImFilterScreenState();
}

class _ImFilterScreenState extends AppState<ImFilterScreen> with SingleTickerProviderStateMixin {
  late ImFilterController controller;
  UserManager userManager = AppDelegate.instance.getManager();

  @override
  void initState() {
    super.initState();
    if (widget.onCallback != null) {
      controller = Get.find();
      if (controller.rightTabList.contains(Images.ic_effect) == false) {
        controller.rightTabList.insert(0, Images.ic_effect);
      }
    } else {
      controller = Get.put(ImFilterController());
      controller.filePath = widget.filePath;
    }
    controller.selectedRightTab = widget.tab;
    controller.preSelectedTab = widget.tab;
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      if (widget.tab == TABS.BACKGROUND) {
        controller.onSelectImage(controller.filePath!);
        onTapRemoveBg();
      }
    });
  }

  onTapRemoveBg() {
    if (controller.personImageByte == null) {
      Navigator.push(
        context,
        NoAnimRouter(
          ImRemoveBgScreen(
            filePath: controller.filePath!,
            imageRatio: controller.imageRatio,
            onGetRemoveBgImage: (String img) async {
              File file = File(img);
              controller.personImage = await getLibImage(await getImage(file));
              controller.personImageByte = file.readAsBytesSync();
              controller.personImageForUi = await controller.convertImage(controller.personImage);
              controller.byte = controller.personImageByte;
              controller.selectedRightTab = TABS.BACKGROUND;
              setState(() {});
            },
          ),
          // opaque: true,
          settings: RouteSettings(name: "/ImRemoveBgScreen"),
        ),
      ).then((value) => {
            if (value != true)
              {
                // 退回到原来的tab
                Navigator.of(context).pop()
              },
          });
    } else {
      controller.byte = controller.personImageByte;
      controller.selectedRightTab = TABS.BACKGROUND;
      setState(() {});
    }
    return;
  }

  @override
  void dispose() {
    super.dispose();
    if (widget.onCallback == null) {
      Get.delete<ImFilterController>();
    }
  }

  Widget _buildRightTab() {
    List<Widget> buttons = [];
    int num = widget.onCallback != null ? 0 : 1;
    for (var img in controller.rightTabList) {
      int cur = num;
      buttons.add(GestureDetector(
        onTap: () async {
          if (TABS.values[cur] == TABS.BACKGROUND) {
            onTapRemoveBg();
            return;
          } else if (TABS.values[cur] == TABS.ADJUST)
            controller.byte = Uint8List.fromList(imgLib.encodeJpg(await controller.adjust.ImAdjust(controller.image)));
          else
            controller.byte = Uint8List.fromList(imgLib.encodeJpg(await controller.image));
          setState(() {
            if (TABS.EFFECT == TABS.values[cur]) {
              Navigator.of(context).pop();
              return;
            }
            controller.selectedRightTab = TABS.values[cur];
            controller.byte;
          });
        },
        child: Container(
          width: $(40),
          height: $(40),
          decoration: (controller.selectedRightTab == TABS.values[cur])
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
          controller.originalShowing = true;
        });
      },
      onTapUp: (TapUpDetails details) {
        setState(() {
          controller.originalShowing = false;
        });
      },
      onTapCancel: () {
        setState(() {
          controller.originalShowing = false;
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
        width: $(50),
        margin: EdgeInsets.only(right: $(10)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                decoration: BoxDecoration(color: Color.fromARGB(100, 22, 44, 33), borderRadius: BorderRadius.all(Radius.circular($(50)))),
                padding: EdgeInsets.symmetric(horizontal: $(5), vertical: $(10)),
                height: controller.rightTabList.length * $(40) + $(20),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: buttons)),
            SizedBox(height: $(50)),
            (controller.selectedRightTab != TABS.CROP)
                ? Container(
                    decoration: BoxDecoration(color: Color.fromARGB(100, 22, 44, 33), borderRadius: BorderRadius.all(Radius.circular($(50)))),
                    height: $(42),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: adjustbutton))
                : Container()
          ],
        ),
      ),
    );
  }

  Widget _buildImageView() {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        GetBuilder<ImFilterController>(
            init: controller,
            builder: (context) {
              return Container(
                margin: EdgeInsets.only(top: $(5)),
                child: controller.byte != null
                    ? controller.originalShowing
                        ? Container(
                            child: Image.file(controller.imageFile, fit: BoxFit.contain),
                          )
                        : (controller.selectedRightTab == TABS.CROP && controller.crop.selectedID > 0)
                            ? Center(
                                child: DecorationCropper(
                                cropperKey: controller.cropperKey,
                                crop: controller.crop,
                                byte: controller.byte,
                                globalKey: controller.ImageViewerBackgroundKey,
                              ))
                            : Image.memory(
                                controller.byte!,
                                fit: BoxFit.contain,
                              )
                    : Container(),
              );
            }),
        _buildRightTab()
      ],
    );
  }

  Widget _buildEffectController() {
    return SizedBox(
      height: $(85),
    );
  }

  Widget _buildFiltersController() {
    return ScrollablePositionedList.separated(
      initialScrollIndex: 0,
      itemCount: controller.filter.avatars.length,
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        var item = Container(
            width: $(63),
            height: $(63),
            margin: EdgeInsets.all(2.5),
            child: Image.memory(
              controller.filter.avatars[index],
              fit: BoxFit.cover,
            ));
        return GestureDetector(
            onTap: () {
              setState(() {
                controller.filter.setSelectedID(index);
                controller.InnerFilter(Filter.filters[index]);
              });
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                controller.filter.getSelectedID() == index
                    ? OutlineWidget(
                        strokeWidth: 3,
                        radius: $(2),
                        gradient: LinearGradient(
                          colors: [Color(0xFF04F1F9), Color(0xFF7F97F3), Color(0xFFEC5DD8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        child: item)
                    : item,
                SizedBox(height: $(2)),
                Text(
                  Filter.filters[index],
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ],
            ));
      },
      separatorBuilder: (BuildContext context, int index) {
        return Container(
          width: $(2),
        );
      },
    ).intoContainer(
      height: $(100),
    );
  }

  Widget _buildAdjust() {
    final ScrollController _scrollController = ScrollController();
    List<Widget> buttons = [];
    buttons.add(SizedBox(width: MediaQuery.of(context).size.width / 2 - ($(45) / 2)));
    for (int i = 0; i < controller.adjust.getCnt(); i++) {
      int cur_i = i;
      buttons.add(GestureDetector(
          onTap: () async {
            if (controller.adjust.getSelectedID() == cur_i && !controller.adjust.isInitalized) {
              controller.adjust.previousValue = controller.adjust.getSelectedValue();
              controller.adjust.setSliderValue(controller.adjust.initSliderValues[cur_i]);
              controller.adjust.isInitalized = true;
              setState(() {
                controller.adjust;
              });
              if (controller.imageFile != null) {
                controller.byte = Uint8List.fromList(imgLib.encodeJpg(await controller.adjust.ImAdjust(controller.image)));
                setState(() {});
              }
            } else if (controller.adjust.getSelectedID() == cur_i && controller.adjust.isInitalized) {
              controller.adjust.setSliderValue(controller.adjust.previousValue);
              controller.adjust.isInitalized = false;
              setState(() {
                controller.adjust;
              });
              if (controller.imageFile != null) {
                controller.byte = Uint8List.fromList(imgLib.encodeJpg(await controller.adjust.ImAdjust(controller.image)));
                setState(() {
                  controller.byte;
                });
              }
            } else {
              setState(() {
                controller.adjust.setSelectedID(cur_i);
              });
            }
            _scrollController.animateTo(
              $(74) * cur_i,
              duration: Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          },
          child: (controller.adjust.getSelectedID() != cur_i)
              ? Stack(children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: (controller.adjust.getSelectedID() == cur_i) ? Border.all(color: const Color(0xFF05E0D5), width: $(2)) : Border.all(color: Colors.grey, width: $(2)),
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
                    (controller.adjust.getSelectedValue() >= 0)
                        ? AppCircleProgressBar(
                            size: $(45),
                            ringWidth: $(2),
                            backgroundColor: Colors.grey,
                            progress: controller.adjust.getSelectedValue() / (controller.adjust.range[controller.adjust.selectedID][1]),
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
                            progress: 1 - controller.adjust.getSelectedValue() / controller.adjust.range[controller.adjust.selectedID][0],
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
                        controller.adjust.getSliderValue(cur_i).toInt().toString(),
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

    return Column(children: [
      Text(
        Adjust.filters[controller.adjust.selectedID],
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
      SizedBox(height: $(5)),
      GridSlider(
          minVal: controller.adjust.range[controller.adjust.selectedID][0],
          maxVal: controller.adjust.range[controller.adjust.selectedID][1],
          currentPos: controller.adjust.getSelectedValue(),
          onChanged: (newValue) {
            controller.adjust.setSliderValue(newValue);
            controller.adjust.isInitalized = false;
            // setState(() {
            //   controller.adjust;
            // });
          },
          onEnd: () async {
            if (controller.imageFile != null) {
              controller.byte = Uint8List.fromList(imgLib.encodeJpg(await controller.adjust.ImAdjust(controller.image)));
              setState(() {
                controller.byte;
              });
            }
          })
    ]);
  }

  Widget _buildCrops() {
    List<Widget> buttons = [];
    int i = 0;
    for (String title in controller.crop.titles[controller.crop.isPortrait]) {
      int curi = i;
      buttons.add(GestureDetector(
        onTap: () {
          setState(() {
            controller.crop.selectedID = curi;
            controller.crop.isPortrait = controller.crop.isPortrait;
            // crop.aspectRatio = crop.ratios[curi][0] / crop.ratios[curi][1];
          });
        },
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(color: (controller.crop.selectedID == curi) ? Color(0xFF05E0D5) : Colors.white),
            )
          ],
        ),
      ));
      buttons.add(SizedBox(
        width: $(30),
      ));
      i++;
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: $(16)),
        (controller.crop.selectedID >= 2)
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () {
                      // Handle button press
                      setState(() {
                        controller.crop.isPortrait = 0;
                      });
                      print('Button pressed!');
                    },
                    child: Container(
                      child: (controller.crop.isPortrait == 0) ? Image.asset(Images.ic_landscape_selected) : Image.asset(Images.ic_landscape), // Replace with your image path
                    ),
                  ),
                  SizedBox(width: $(30)),
                  InkWell(
                    onTap: () {
                      // Handle button press
                      setState(() {
                        controller.crop.isPortrait = 1;
                      });
                      print('Button pressed!');
                    },
                    child: Container(
                      child: (controller.crop.isPortrait == 1) ? Image.asset(Images.ic_portrat_selected) : Image.asset(Images.ic_portrat), // Replace with your image path
                    ),
                  )
                ],
              )
            : SizedBox(height: $(32)),
        SizedBox(height: $(32)),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: buttons,
        )
      ],
    );
  }

  void showPersonEditScreenDialog(BuildContext context) {
    Navigator.push(
      context,
      NoAnimRouter(
        settings: RouteSettings(name: "/ImEffectScreen"),
        ImPinView(
          personImage: controller.personImage,
          personImageForUI: controller.personImageForUi,
          backgroundImage: controller.backgroundImage,
          backgroundColor: controller.backgroundColor,
          onAddImage: (image) {
            Uint8List byte = Uint8List.fromList(imgLib.encodeJpg(image));
            controller.byte = byte;
            setState(() {});
          },
        ),
      ),
    );
    // showDialog(
    //   context: context,
    //   builder: (BuildContext context) {
    //     return Dialog(
    //         // Adjust the following properties to make the dialog full screen
    //         insetPadding: EdgeInsets.all(0),
    //         child: Container(
    //           decoration: BoxDecoration(
    //             color: Colors.black, // Set your desired background color here
    //           ),
    //           child: ImPinView(
    //             personImage: controller.personImage,
    //             personImageForUI: controller.personImageForUi,
    //             backgroundImage: controller.backgroundImage,
    //             backgroundColor: controller.backgroundColor,
    //             onAddImage: (image) {
    //               Navigator.of(context).pop(Uint8List.fromList(imgLib.encodeJpg(image)));
    //             },
    //           ),
    //         ));
    //   },
    // ).then((byte) {
    //   setState(() {
    //     controller.byte = byte;
    //   });
    // });
  }

  Color rgbaToAbgr(Color rgbaColor) {
    int abgrValue = (rgbaColor.alpha << 24) | (rgbaColor.blue << 16) | (rgbaColor.green << 8) | rgbaColor.red;
    return Color(abgrValue);
  }

  Widget _buildBackground(BuildContext context) {
    return BackgroundPickerBar(
      imageRatio: controller.imageRatio,
      onPick: (BackgroundData data) async {
        // _backgroundImage = await backgroundRemoval.addBackgroundImage(_personImage, data.filePath!);
        if (data.filePath != null) {
          File backFile = File(data.filePath!);
          controller.backgroundColor = null;
          controller.backgroundImage = await getLibImage(await getImage(backFile));
        } else {
          controller.backgroundImage = null;
          controller.backgroundColor = rgbaToAbgr(data.color!);
          // controller.backgroundImage = imgLib.Image(controller.personImage.width, controller.personImage.height);
          // imgLib.fill(controller.backgroundImage, rgbaToAbgr(data.color!).value);
        }
        controller.update();
        showPersonEditScreenDialog(context);
      },
    ).intoContainer(
      width: double.maxFinite,
      padding: EdgeInsets.symmetric(horizontal: $(4)),
    );
  }

  Widget _buildBottomTabbar(BuildContext context) {
    return GetBuilder<ImFilterController>(
        init: controller,
        builder: (controller) {
          switch (controller.selectedRightTab) {
            case TABS.EFFECT:
              return _buildEffectController();
            case TABS.FILTER:
              return _buildFiltersController();
            case TABS.ADJUST:
              return _buildAdjust();
            case TABS.CROP:
              return _buildCrops();
            case TABS.BACKGROUND:
              return _buildBackground(context);
            default:
              return Container(height: $(85));
          }
        });
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.BackgroundColor,
      body: Column(
        children: [
          buildAppNavigationBar(context),
          Expanded(child: _buildImageView().hero(tag: EffectImageViewTag)),
          // _buildInOutControlPad().hero(tag: EffectInOutControlPadTag),
          // SizedBox(height: $(8)),
          _buildBottomTabbar(context),
          SizedBox(height: ScreenUtil.getBottomPadding(context) + $(10)),
        ],
      ),
    );
  }

  shareOut(BuildContext context) async {
    AppDelegate.instance.getManager<ThirdpartManager>().adsHolder.ignore = true;
    // controller.byte
    // var uint8list = await ImageUtils.printStyleMorphDrawData(controller.imageFile, File(controller.filePath!), '@${userManager.user?.getShownName() ?? 'Pandora User'}');
    ShareScreen.startShare(context,
        backgroundColor: Color(0x77000000),
        style: "filter_edit",
        image: base64Encode(controller.byte!),
        isVideo: false,
        originalUrl: null,
        effectKey: "", onShareSuccess: (platform) {
      Events.styleFilterCompleteShare(source: "filter_edit", platform: platform, type: 'image');
    });
    AppDelegate.instance.getManager<ThirdpartManager>().adsHolder.ignore = false;
  }

  shareToDiscovery(BuildContext context) async {
    // todo：还未确定是否分享到发现
    return;
    // if (TextUtil.isEmpty(controller.uploadImageController.imageUrl.value)) {
    //   await showLoading();
    //   String key = await md5File(controller.imageFile);
    //   var needUpload = await controller.uploadImageController.needUploadByKey(key);
    //   if (needUpload) {
    //     File compressedImage = await imageCompressAndGetFile(controller.imageFile);
    //     await controller.uploadImageController.uploadCompressedImage(compressedImage, key: key);
    //     await hideLoading();
    //     if (TextUtil.isEmpty(controller.uploadImageController.imageUrl.value)) {
    //       return;
    //     }
    //   } else {
    //     await hideLoading();
    //   }
    // }
    // AppDelegate.instance.getManager<UserManager>().doOnLogin(context, logPreLoginAction: 'share_discovery_from_cartoonize', callback: () {
    //   var file = File(controller.filePath!);
    //   ShareDiscoveryScreen.push(
    //     context,
    //     // todo
    //     effectKey: "",
    //     originalUrl: controller.uploadImageController.imageUrl.value,
    //     image: base64Encode(file.readAsBytesSync()),
    //     isVideo: false,
    //     category: HomeCardType.cartoonize,
    //   ).then((value) {
    //     if (value ?? false) {
    //       controller.onResultShare(source: 'gallery', platform: 'effect', photo: 'image');
    //       showShareSuccessDialog(context);
    //     }
    //   });
    // }, autoExec: true);
  }

  Widget buildAppNavigationBar(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          Images.ic_back,
          width: $(24),
        )
            .intoContainer(
              padding: EdgeInsets.symmetric(horizontal: $(8), vertical: $(8)),
              color: Colors.transparent,
            )
            .hero(tag: ImFilter.TagAppbarTagBack)
            .intoGestureDetector(onTap: () {
          widget.onCallback?.call();
          pop();
        }),
        Expanded(
            child: Image.asset(Images.ic_download, height: $(24), width: $(24))
                .intoContainer(padding: EdgeInsets.all($(8)))
                .hero(tag: ImFilter.TagAppbarTagTitle)
                .intoGestureDetector(
                  onTap: () {
                    controller.saveToAlbum(context);
                  },
                )
                .intoCenter()
                .intoContainer(margin: EdgeInsets.symmetric(horizontal: $(8)))),
        Image.asset(
          Images.ic_more,
          width: $(24),
        )
            .intoContainer(
              padding: EdgeInsets.symmetric(horizontal: $(8), vertical: $(8)),
              color: Colors.transparent,
            )
            .hero(tag: ImFilter.TagAppbarTagTraining)
            .intoGestureDetector(onTap: () async {
          LiPopMenu.showLinePop(
            context,
            listData: [
              ListPopItem(
                  text: S.of(context).share_to_discovery,
                  icon: Images.ic_share_discovery,
                  onTap: () {
                    shareToDiscovery(context);
                  }),
              ListPopItem(
                  text: S.of(context).share_out,
                  icon: Images.ic_share,
                  onTap: () {
                    shareOut(context);
                  }),
            ],
          );
        }),
      ],
    ).intoContainer(height: kNavBarPersistentHeight, margin: EdgeInsets.only(top: ScreenUtil.getStatusBarHeight()));
  }
}
