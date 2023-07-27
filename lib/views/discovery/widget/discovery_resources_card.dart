import 'dart:convert';
import 'dart:math';

import 'package:cartoonizer/Widgets/cacheImage/cached_network_image_utils.dart';
import 'package:cartoonizer/Widgets/image/sync_download_image.dart';
import 'package:cartoonizer/Widgets/image/sync_image_provider.dart';
import 'package:cartoonizer/Widgets/video/effect_video_player.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/models/discovery_list_entity.dart';
import 'package:cartoonizer/utils/ffmpeg_util.dart';
import 'package:cartoonizer/utils/utils.dart';

import '../../../Common/importFile.dart';
import '../../../Widgets/image/sync_download_video.dart';

enum AlignType {
  first,
  last,
  maxOne,
  minOne,
}

typedef PlaceholderWidgetBuilder = Widget Function(BuildContext context, DiscoveryResource data, double width, double height);

class DiscoveryResourcesCard extends StatelessWidget {
  final AlignType alignType;
  final List<DiscoveryResource> datas;
  final double space;
  final PlaceholderWidgetBuilder placeholderWidgetBuilder;
  final Function(DiscoveryResource data, int index)? onTap;

  const DiscoveryResourcesCard({
    super.key,
    this.alignType = AlignType.last,
    required this.datas,
    this.space = 1,
    required this.placeholderWidgetBuilder,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    var widthTotal = ScreenUtil.getCurrentWidgetSize(context).width;
    var width = (widthTotal - (space * datas.length - 1)) / max(datas.length, 1);
    return Row(
      children: datas.transfer(
        (e, index) => Expanded(child: buildItem(e, context, width, index), flex: 1),
      ),
    );
  }

  Widget buildItem(DiscoveryResource e, BuildContext context, double width, int index) {
    if (e.type == DiscoveryResourceType.image) {
      return CachedNetworkImageUtils.custom(
        context: context,
        imageUrl: e.url!,
        placeholder: (context, url) {
          return placeholderWidgetBuilder.call(context, e, width, width);
        },
      ).intoGestureDetector(
          onTap: onTap == null
              ? null
              : () {
                  onTap?.call(e, index);
                });
    } else {
      return EffectVideoPlayer(url: e.url!);
    }
  }
}

class DiscoveryResourcesCard2 extends StatefulWidget {
  final AlignType alignType;
  final List<DiscoveryResource> datas;
  final double space;
  final PlaceholderWidgetBuilder placeholderWidgetBuilder;
  final Function(DiscoveryResource data, int index)? onTap;

  const DiscoveryResourcesCard2({
    super.key,
    this.alignType = AlignType.last,
    required this.datas,
    this.space = 1,
    required this.placeholderWidgetBuilder,
    this.onTap,
  });

  @override
  State<DiscoveryResourcesCard2> createState() => _DiscoveryResourcesCardState();
}

class _DiscoveryResourcesCardState extends State<DiscoveryResourcesCard2> {
  late AlignType alignType;
  List<DiscoveryResource> datas = [];
  double itemWidth = 0;
  double itemHeight = 0;
  late double space;
  late PlaceholderWidgetBuilder placeholderWidgetBuilder;
  Function(DiscoveryResource data, int index)? onTap;
  double totalWidth = 0;

  @override
  void didUpdateWidget(covariant DiscoveryResourcesCard2 oldWidget) {
    super.didUpdateWidget(oldWidget);
    var newString = jsonEncode(widget.datas.map((e) => e.toJson()).toList());
    var oldString = jsonEncode(datas.map((e) => e.toJson()).toList());
    if (newString != oldString) {
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
    datas = widget.datas;
    placeholderWidgetBuilder = widget.placeholderWidgetBuilder;
    onTap = widget.onTap;
    delay(() {
      if (!mounted) {
        return;
      }
      totalWidth = ScreenUtil.getCurrentWidgetSize(context).width;
      var imgTotalWidth = totalWidth - space * datas.length - 1;
      itemWidth = imgTotalWidth / datas.length;
      calculateSize();
      if (mounted) {
        setState(() {});
      }
    });
  }

  calculateSize() {
    switch (alignType) {
      case AlignType.first:
        var item = datas.first;
        if (item.type == DiscoveryResourceType.image) {
          SyncCachedNetworkImage(url: item.url!).getImage().then((value) {
            itemHeight = itemWidth / (value.image.width / value.image.height);
            if (mounted) {
              setState(() {});
            }
          });
        } else {
          SyncDownloadVideo(type: getFileType(item.url!), url: item.url!).getVideo().then((value) {
            if (value != null) {
              FFmpegUtil.getVideoRatio(value.path).then((value) {
                if (value != null) {
                  itemHeight = itemWidth / value;
                } else {
                  itemHeight = itemWidth;
                }
                if (mounted) {
                  setState(() {});
                }
              });
            }
          });
        }
        break;
      case AlignType.last:
        var item = datas.last;
        if (item.type == DiscoveryResourceType.image) {
          SyncCachedNetworkImage(url: item.url!).getImage().then((value) {
            itemHeight = itemWidth / (value.image.width / value.image.height);
            if (mounted) {
              setState(() {});
            }
          });
        } else {
          SyncDownloadVideo(type: getFileType(item.url!), url: item.url!).getVideo().then((value) {
            if (value != null) {
              FFmpegUtil.getVideoRatio(value.path).then((value) {
                if (value != null) {
                  itemHeight = itemWidth / value;
                } else {
                  itemHeight = itemWidth;
                }
                if (mounted) {
                  setState(() {});
                }
              });
            }
          });
        }
        break;
      case AlignType.maxOne:
        for (var value in datas) {
          if (value.type == DiscoveryResourceType.image) {
            SyncCachedNetworkImage(url: value.url!).getImage().then((value) {
              var height = itemWidth / (value.image.width / value.image.height);
              if (height > itemHeight) {
                itemHeight = height;
              }
              if (mounted) {
                setState(() {});
              }
            });
          } else {
            SyncDownloadVideo(type: getFileType(value.url!), url: value.url!).getVideo().then((value) {
              if (value != null) {
                FFmpegUtil.getVideoRatio(value.path).then((value) {
                  if (value != null) {
                    var height = itemHeight = itemWidth / value;
                    if (height > itemHeight) {
                      itemHeight = height;
                    }
                  }
                  if (mounted) {
                    setState(() {});
                  }
                });
              }
            });
          }
        }
        break;
      case AlignType.minOne:
        for (var value in datas) {
          if (value.type == DiscoveryResourceType.image) {
            SyncCachedNetworkImage(url: value.url!).getImage().then((value) {
              var height = itemWidth / (value.image.width / value.image.height);
              if (itemHeight == 0) {
                itemHeight = height;
              }
              if (height < itemHeight) {
                itemHeight = height;
              }
              if (mounted) {
                setState(() {});
              }
            });
          } else {
            SyncDownloadVideo(type: getFileType(value.url!), url: value.url!).getVideo().then((value) {
              if (value != null) {
                FFmpegUtil.getVideoRatio(value.path).then((value) {
                  if (value != null) {
                    var height = itemHeight = itemWidth / value;
                    if (itemHeight == 0) {
                      itemHeight = height;
                    }
                    if (height < itemHeight) {
                      itemHeight = height;
                    }
                  }
                  if (mounted) {
                    setState(() {});
                  }
                });
              }
            });
          }
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (itemWidth == 0) {
      return Container();
    }
    if (itemHeight == 0) {
      return Row(
        children: datas.transfer(
          (e, index) => placeholderWidgetBuilder.call(context, e, itemWidth, itemWidth).intoContainer(margin: EdgeInsets.only(left: index == 0 ? 0 : space)),
        ),
      ).intoContainer(width: totalWidth);
    }
    if (!TickerMode.of(context)) {
      return SizedBox(width: ScreenUtil.getCurrentWidgetSize(context).width, height: itemHeight);
    }
    return Row(
      children: datas.transfer((e, index) {
        if (e.type == DiscoveryResourceType.image) {
          return CachedNetworkImageUtils.custom(
            context: context,
            imageUrl: e.url!,
            placeholder: (context, url) => placeholderWidgetBuilder.call(context, e, itemWidth, itemHeight),
            width: itemWidth,
            height: itemHeight,
            useOld: false,
            fit: BoxFit.cover,
            errorWidget: (context, url, error) => placeholderWidgetBuilder.call(context, e, itemWidth, itemHeight),
          )
              .intoGestureDetector(
                  onTap: onTap == null
                      ? null
                      : () {
                          onTap?.call(e, index);
                        })
              .intoContainer(margin: EdgeInsets.only(left: index == 0 ? 0 : space), height: itemHeight, width: itemWidth);
        } else {
          return EffectVideoPlayer(
            url: e.url!,
            loop: true,
          )
              .intoGestureDetector(
                  onTap: onTap == null
                      ? null
                      : () {
                          onTap?.call(e, index);
                        })
              .intoContainer(margin: EdgeInsets.only(left: index == 0 ? 0 : space), height: itemHeight, width: itemWidth, alignment: Alignment.center);
        }
      }),
    ).intoContainer(height: itemHeight, width: totalWidth);
  }
}
