import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cartoonizer/common/Extension.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/widgets/cacheImage/image_cache_manager.dart';
import 'package:cartoonizer/widgets/dialog/dialog_widget.dart';
import 'package:cartoonizer/widgets/image/sync_download_image.dart';
import 'package:cartoonizer/widgets/state/app_state.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/thirdpart/thirdpart_manager.dart';
import 'package:cartoonizer/gallery_saver.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/views/share/ShareScreen.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class GalleryPhotoViewWrapper extends StatefulWidget {
  GalleryPhotoViewWrapper({
    this.loadingBuilder,
    this.backgroundDecoration,
    this.minScale,
    this.maxScale,
    this.initialIndex = 0,
    required this.galleryItems,
    this.scrollDirection = Axis.horizontal,
    this.shareEnable = false,
    this.onDownloadImage,
    this.onShareImage,
  }) : pageController = PageController(initialPage: initialIndex);

  final Function(String url)? onDownloadImage;
  final Function(String url, String platform)? onShareImage;

  final LoadingBuilder? loadingBuilder;
  final BoxDecoration? backgroundDecoration;
  final dynamic minScale;
  final dynamic maxScale;
  final int initialIndex;
  final PageController pageController;
  final List<String> galleryItems;
  final Axis scrollDirection;
  final bool shareEnable;

  @override
  State<StatefulWidget> createState() {
    return _GalleryPhotoViewWrapperState();
  }
}

class _GalleryPhotoViewWrapperState extends AppState<GalleryPhotoViewWrapper> {
  late int currentIndex = widget.initialIndex;

  void onPageChanged(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.BackgroundColor,
      body: Stack(
        children: [
          PhotoViewGallery.builder(
            scrollPhysics: const BouncingScrollPhysics(),
            builder: _buildItem,
            itemCount: widget.galleryItems.length,
            loadingBuilder: widget.loadingBuilder,
            backgroundDecoration: widget.backgroundDecoration,
            pageController: widget.pageController,
            onPageChanged: onPageChanged,
            scrollDirection: widget.scrollDirection,
            allowImplicitScrolling: true,
          ).intoGestureDetector(onTap: () {
            Navigator.of(context).pop();
          }),
          widget.shareEnable
              ? Positioned(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        Images.ic_download,
                        width: $(20),
                      )
                          .intoContainer(
                        padding: EdgeInsets.all($(6)),
                        margin: EdgeInsets.all($(6)),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade800,
                          borderRadius: BorderRadius.circular(32),
                        ),
                      )
                          .intoGestureDetector(onTap: () async {
                        showLoading().whenComplete(() async {
                          var file = await SyncDownloadImage(url: widget.galleryItems[currentIndex], type: 'png').getImage();
                          if (file != null) {
                            await GallerySaver.saveImage(file.path, albumName: 'Pandora Avatars');
                            widget.onDownloadImage?.call(widget.galleryItems[currentIndex]);
                            hideLoading().whenComplete(() {
                              CommonExtension().showImageSavedOkToast(context);
                            });
                          } else {
                            hideLoading();
                          }
                        });
                      }),
                      SizedBox(width: 8),
                      Image.asset(
                        Images.ic_share,
                        color: Colors.white,
                        width: $(20),
                      )
                          .intoContainer(
                        padding: EdgeInsets.all($(6)),
                        margin: EdgeInsets.all($(6)),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade800,
                          borderRadius: BorderRadius.circular(32),
                        ),
                      )
                          .intoGestureDetector(onTap: () {
                        var item = widget.galleryItems[currentIndex];
                        showLoading().whenComplete(() {
                          SyncDownloadImage(url: item, type: 'png').getImage().then((image) {
                            hideLoading().whenComplete(() {
                              var imageString = base64Encode(image!.readAsBytesSync());
                              AppDelegate.instance.getManager<ThirdpartManager>().adsHolder.ignore = true;
                              ShareScreen.startShare(context,
                                  backgroundColor: Color(0x77000000),
                                  style: 'PandoraAI',
                                  image: imageString,
                                  isVideo: false,
                                  originalUrl: null,
                                  effectKey: 'PandoraAI',
                                  needDiscovery: true, onShareSuccess: (platform) {
                                widget.onShareImage?.call(widget.galleryItems[currentIndex], platform);
                              }).then((value) {
                                if (value ?? false) {
                                  showShareSuccessDialog(context);
                                }
                                AppDelegate.instance.getManager<ThirdpartManager>().adsHolder.ignore = false;
                              });
                            });
                          });
                        });
                      }),
                    ],
                  )
                      .intoContainer(
                          alignment: Alignment.centerRight,
                          width: double.maxFinite,
                          color: Colors.transparent,
                          padding: EdgeInsets.only(
                            bottom: ScreenUtil.getBottomPadding(context) == 0 ? $(15) : ScreenUtil.getBottomPadding(context),
                            top: $(10),
                            left: $(10),
                            right: $(15),
                          ))
                      .intoGestureDetector(onTap: () {}),
                  bottom: 0,
                  left: 0,
                  right: 0,
                )
              : Container(),
        ],
      ),
    );
  }

  PhotoViewGalleryPageOptions _buildItem(BuildContext context, int index) {
    final String url = widget.galleryItems[index];
    return PhotoViewGalleryPageOptions(
      imageProvider: CachedNetworkImageProvider(url, cacheManager: CachedImageCacheManager()),
      initialScale: PhotoViewComputedScale.contained,
      minScale: PhotoViewComputedScale.contained * 0.5,
      maxScale: PhotoViewComputedScale.covered * 4.1,
      heroAttributes: PhotoViewHeroAttributes(tag: url),
    );
  }
}
