import 'dart:convert';
import 'dart:io';

import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/image/sync_download_image.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/api/cartoonizer_api.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/cache/storage_operator.dart';
import 'package:cartoonizer/app/thirdpart/thirdpart_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/common/Extension.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/gallery_saver.dart';
import 'package:cartoonizer/models/discovery_list_entity.dart';
import 'package:cartoonizer/utils/img_utils.dart';
import 'package:cartoonizer/utils/string_ex.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:cartoonizer/views/share/ShareScreen.dart';
import 'package:cartoonizer/views/social/metagram_controller.dart';
import 'package:common_utils/common_utils.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

import 'comments/metagram_comments_screen.dart';
import 'edit/metagram_item_edit_screen.dart';
import 'widget/metagram_list_card.dart';

class MetagramItemListScreen extends StatefulWidget {
  const MetagramItemListScreen({Key? key}) : super(key: key);

  @override
  State<MetagramItemListScreen> createState() => _MetagramItemListScreenState();
}

class _MetagramItemListScreenState extends AppState<MetagramItemListScreen> {
  MetagramController controller = Get.find<MetagramController>();

  @override
  void initState() {
    super.initState();
    Posthog().screen(screenName: 'metagram_list_screen');
    delay(() {
      controller.itemScrollController.jumpTo(
        index: controller.scrollPosition,
      );
    });
  }

  void shareOutImage(List<DiscoveryResource> items) async {
    await showLoading();
    UserManager userManager = AppDelegate.instance.getManager();
    var originFile = await SyncDownloadImage(url: items.last.url!, type: getFileType(items.last.url!).fileImageType).getImage();
    var resultFile = await SyncDownloadImage(url: items.first.url!, type: getFileType(items.first.url!).fileImageType).getImage();
    if (originFile == null || resultFile == null) {
      await hideLoading();
      CommonExtension().showToast('Image Load Failed');
      return;
    }
    var uint8list = await ImageUtils.printAnotherMeData(originFile, resultFile, '@${userManager.user?.getShownName() ?? 'Pandora User'}');
    await hideLoading();
    AppDelegate.instance.getManager<ThirdpartManager>().adsHolder.ignore = true;
    ShareScreen.startShare(context,
        backgroundColor: Color(0x77000000),
        style: 'Metagram',
        image: base64Encode(uint8list),
        isVideo: false,
        originalUrl: null,
        effectKey: 'Me-taverse', onShareSuccess: (platform) {
      Events.metagramCompleteShare(source: 'metagram', platform: platform, type: 'image');
    });
    AppDelegate.instance.getManager<ThirdpartManager>().adsHolder.ignore = false;
  }

  void saveImage(List<DiscoveryResource> items) async {
    await showLoading();
    UserManager userManager = AppDelegate.instance.getManager();
    var path = AppDelegate.instance.getManager<CacheManager>().storageOperator.tempDir.path;
    var saveFileName = EncryptUtil.encodeMd5('${items.last.url}${items.first.url}');
    var imgPath = path + '${saveFileName}.png';
    if (!File(imgPath).existsSync()) {
      var originFile = await SyncDownloadImage(url: items.last.url!, type: getFileType(items.last.url!).fileImageType).getImage();
      var resultFile = await SyncDownloadImage(url: items.first.url!, type: getFileType(items.first.url!).fileImageType).getImage();
      if (originFile == null || resultFile == null) {
        await hideLoading();
        CommonExtension().showToast('Image Load Failed');
        return;
      }
      var uint8list = await ImageUtils.printAnotherMeData(originFile, resultFile, '@${userManager.user?.getShownName() ?? 'Pandora User'}');
      var list = uint8list.toList();
      await File(imgPath).writeAsBytes(list);
    }
    await GallerySaver.saveImage(imgPath, albumName: saveAlbumName);
    await hideLoading();
    Events.metagramCompleteDownload(type: 'image');
    CommonExtension().showImageSavedOkToast(context);
    delay(() {
      userManager.rateNoticeOperator.onSwitch(context);
    }, milliseconds: 2000);
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.BackgroundColor,
      appBar: AppNavigationBar(backgroundColor: ColorConstant.BackgroundColor),
      body: GetBuilder<MetagramController>(
        builder: (controller) {
          return ScrollablePositionedList.builder(
              itemPositionsListener: controller.itemPositionsListener,
              itemScrollController: controller.itemScrollController,
              itemCount: controller.data!.rows.length,
              itemBuilder: (context, index) {
                var data = controller.data!.rows[index];
                return MetagramListCard(
                  data: data,
                  isSelf: controller.isSelf,
                  onCommentsTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      settings: RouteSettings(name: "/MetagramCommentsScreen"),
                      builder: (context) => MetagramCommentsScreen(
                        data: data,
                      ),
                    ));
                  },
                  liked: data.liked.value,
                  onLikeTap: (liked) async {
                    UserManager userManager = AppDelegate.instance.getManager();
                    if (userManager.isNeedLogin) {
                      userManager.doOnLogin(context, logPreLoginAction: data.likeId == null ? 'pre_metagram_like' : 'pre_metagram_unlike');
                      return liked;
                    }
                    bool result;
                    controller.likeLocalAddAlready.value = true;
                    if (liked) {
                      data.likes--;
                      CartoonizerApi().discoveryUnLike(data.id!, data.likeId!).then((value) {
                        if (value == null) {
                          controller.likeLocalAddAlready.value = false;
                        }
                      });
                      result = false;
                      data.liked.value = false;
                    } else {
                      data.likes++;
                      CartoonizerApi().discoveryLike(data.id!, source: 'metagram_item_list_page', style: 'metagram').then((value) {
                        if (value == null) {
                          controller.likeLocalAddAlready.value = false;
                        }
                      });
                      result = true;
                      data.liked.value = true;
                    }
                    return result;
                  },
                  onEditTap: (List<List<DiscoveryResource>> items, int index) {
                    Navigator.of(context)
                        .push(MaterialPageRoute(
                      settings: RouteSettings(name: "/MetagramItemEditScreen"),
                      builder: (context) => MetagramItemEditScreen(entity: data, items: items, index: index, isSelf: controller.isSelf),
                    ))
                        .then((value) {
                      controller.update();
                    });
                  },
                  onDownloadTap: (List<DiscoveryResource> items) {
                    saveImage(items);
                  },
                  onShareOutTap: (List<DiscoveryResource> items) {
                    shareOutImage(items);
                  },
                ).intoContainer(margin: EdgeInsets.only(bottom: $(15)));
              });
        },
        init: Get.find<MetagramController>(),
      ),
    );
  }
}
