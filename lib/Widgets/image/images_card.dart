import 'package:cartoonizer/Widgets/cacheImage/cached_network_image_utils.dart';
import 'package:cartoonizer/Widgets/image/sync_download_image.dart';
import 'package:cartoonizer/Widgets/image/sync_image_provider.dart';
import 'package:cartoonizer/utils/utils.dart';

import '../../Common/importFile.dart';

enum AlignType {
  first,
  last,
  maxOne,
  minOne,
}

typedef PlaceholderWidgetBuilder = Widget Function(BuildContext context, String url, double width, double height);

class ImagesCard extends StatefulWidget {
  final AlignType alignType;
  final List<String> images;
  final double space;
  final PlaceholderWidgetBuilder placeholderWidgetBuilder;
  final Function(String imageUrl, int index)? onTap;

  const ImagesCard({
    super.key,
    this.alignType = AlignType.last,
    required this.images,
    this.space = 1,
    required this.placeholderWidgetBuilder,
    this.onTap,
  });

  @override
  State<ImagesCard> createState() => _ImagesCardState();
}

class _ImagesCardState extends State<ImagesCard> {
  late AlignType alignType;
  late List<String> images;
  double imageWidth = 0;
  double imageHeight = 0;
  late double space;
  late PlaceholderWidgetBuilder placeholderWidgetBuilder;
  Function(String imageUrl, int index)? onTap;
  double totalWidth = 0;

  @override
  void didUpdateWidget(covariant ImagesCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.images.toString() != images.toString()) {
      _init();
    }
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() {
    space = widget.space;
    alignType = widget.alignType;
    images = widget.images;
    placeholderWidgetBuilder = widget.placeholderWidgetBuilder;
    onTap = widget.onTap;
    delay(() {
      if (!mounted) {
        return;
      }
      totalWidth = ScreenUtil.getCurrentWidgetSize(context).width;
      var imgTotalWidth = totalWidth - space * images.length - 1;
      imageWidth = imgTotalWidth / images.length;
      calculateSize();
      if (mounted) {
        setState(() {});
      }
    });
  }

  calculateSize() {
    switch (alignType) {
      case AlignType.first:
        SyncDownloadImage(type: getFileType(images.first), url: images.first).getImage().then((value) {
          SyncFileImage(file: value!).getImage().then((value) {
            imageHeight = imageWidth / (value.image.width / value.image.height);
            if (mounted) {
              setState(() {});
            }
          });
        });
        break;
      case AlignType.last:
        SyncDownloadImage(type: getFileType(images.last), url: images.last).getImage().then((value) {
          SyncFileImage(file: value!).getImage().then((value) {
            imageHeight = imageWidth / (value.image.width / value.image.height);
            if (mounted) {
              setState(() {});
            }
          });
        });
        break;
      case AlignType.maxOne:
        for (var value in images) {
          SyncDownloadImage(type: getFileType(value), url: value).getImage().then((value) {
            SyncFileImage(file: value!).getImage().then((value) {
              var height = imageWidth / (value.image.width / value.image.height);
              if (height > imageHeight) {
                imageHeight = height;
              }
              if (mounted) {
                setState(() {});
              }
            });
          });
        }
        break;
      case AlignType.minOne:
        for (var value in images) {
          SyncDownloadImage(type: getFileType(value), url: value).getImage().then((value) {
            SyncFileImage(file: value!).getImage().then((value) {
              var height = imageWidth / (value.image.width / value.image.height);
              if (imageHeight == 0) {
                imageHeight = height;
              }
              if (height < imageHeight) {
                imageHeight = height;
              }
              if (mounted) {
                setState(() {});
              }
            });
          });
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (imageWidth == 0) {
      return Container();
    }
    if (imageHeight == 0) {
      return Row(
        children: images.transfer(
          (e, index) => placeholderWidgetBuilder.call(context, e, imageWidth, imageWidth).intoContainer(margin: EdgeInsets.only(left: index == 0 ? 0 : space)),
        ),
      ).intoContainer(width: totalWidth);
    }
    return Row(
      children: images.transfer((e, index) => CachedNetworkImageUtils.custom(
            context: context,
            imageUrl: e,
            placeholder: (context, url) => placeholderWidgetBuilder.call(context, e, imageWidth, imageHeight),
            width: imageWidth,
            height: imageHeight,
            useOld: false,
            fit: BoxFit.cover,
            errorWidget: (context, url, error) => placeholderWidgetBuilder.call(context, e, imageWidth, imageHeight),
          )
              .intoGestureDetector(
                  onTap: onTap == null
                      ? null
                      : () {
                          onTap?.call(e, index);
                        })
              .intoContainer(margin: EdgeInsets.only(left: index == 0 ? 0 : space), height: imageHeight, width: imageWidth)),
    ).intoContainer(height: imageHeight, width: totalWidth);
  }
}
