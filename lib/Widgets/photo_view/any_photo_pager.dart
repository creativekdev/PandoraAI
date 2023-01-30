import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/cacheImage/image_cache_manager.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class AnyGalleryPhotoViewWrapper extends StatefulWidget {
  final LoadingBuilder? loadingBuilder;
  final BoxDecoration? backgroundDecoration;
  final dynamic minScale;
  final dynamic maxScale;
  final int initialIndex;
  final PageController pageController;
  final List<AnyPhotoItem> galleryItems;

  AnyGalleryPhotoViewWrapper({
    this.loadingBuilder,
    this.backgroundDecoration,
    this.minScale,
    this.maxScale,
    this.initialIndex = 0,
    required this.galleryItems,
  }) : pageController = PageController(initialPage: initialIndex);

  @override
  State<AnyGalleryPhotoViewWrapper> createState() => _AnyGalleryPhotoViewWrapperState();
}

class _AnyGalleryPhotoViewWrapperState extends AppState<AnyGalleryPhotoViewWrapper> {
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
        body: PhotoViewGallery.builder(
          scrollPhysics: const BouncingScrollPhysics(),
          builder: _buildItem,
          itemCount: widget.galleryItems.length,
          loadingBuilder: widget.loadingBuilder,
          backgroundDecoration: widget.backgroundDecoration,
          pageController: widget.pageController,
          onPageChanged: onPageChanged,
          scrollDirection: Axis.horizontal,
          allowImplicitScrolling: true,
        ).intoGestureDetector(onTap: () {
          Navigator.of(context).pop();
        }));
  }

  PhotoViewGalleryPageOptions _buildItem(BuildContext context, int index) {
    final AnyPhotoItem item = widget.galleryItems[index];
    ImageProvider provider;
    switch (item.type) {
      case AnyPhotoType.assets:
        provider = AssetImage(item.uri);
        break;
      case AnyPhotoType.file:
        provider = FileImage(File(item.uri));
        break;
      case AnyPhotoType.url:
        provider = CachedNetworkImageProvider(item.uri, cacheManager: CachedImageCacheManager());
        break;
      case AnyPhotoType.base64:
        provider = MemoryImage(base64Decode(item.uri));
        break;
    }
    return PhotoViewGalleryPageOptions(
      imageProvider: provider,
      initialScale: PhotoViewComputedScale.contained,
      minScale: PhotoViewComputedScale.contained * 0.5,
      maxScale: PhotoViewComputedScale.covered * 4.1,
      heroAttributes: PhotoViewHeroAttributes(tag: item.tag ?? item.uri),
    );
  }
}

class AnyPhotoItem {
  String uri;
  AnyPhotoType type;
  String? tag;

  AnyPhotoItem({
    required this.type,
    required this.uri,
    this.tag,
  });
}

enum AnyPhotoType {
  assets,
  file,
  url,
  base64,
}
