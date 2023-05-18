import 'dart:ui';

import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/image/sync_image_provider.dart';
import 'package:cartoonizer/app/cache/app_feature_operator.dart';
import 'package:cartoonizer/models/EffectModel.dart';
import 'package:cartoonizer/models/discovery_list_entity.dart';
import 'package:cartoonizer/models/enums/home_card_type.dart';
import 'package:cartoonizer/models/metagram_page_entity.dart';

class MetagramItemEditController extends GetxController {
  MetagramItemEntity entity;

  List<DiscoveryResource> resources = [];

  Size? imageSize;
  Size? resultSize;
  Uint8List? imageData;
  Uint8List? resultData;
  bool _showOrigin = false;
  late HomeCardType currentType;

  set showOrigin(bool value) {
    _showOrigin = value;
    update();
  }

  bool get showOrigin => _showOrigin;

  List<OptItem> optList = [
    OptItem(type: HomeCardType.anotherme),
  ];

  MetagramItemEditController({
    required this.entity,
    EffectModel? fullBody,
  }) {
    if (fullBody != null) {
      optList.add(OptItem(type: HomeCardType.cartoonize, data: fullBody));
    }
  }

  @override
  void onInit() {
    super.onInit();
    currentType = HomeCardTypeUtils.build(entity.category);
    entity.category;
    resources = entity.resourceList();
  }

  @override
  void onReady() {
    super.onReady();
    SyncCachedNetworkImage(url: resources.first.url ?? '').getImage().then((value) {
      imageSize = Size(value.image.width.toDouble(), value.image.height.toDouble());
      update();
      value.image.toByteData(format: ImageByteFormat.png).then((value) {
        imageData = value!.buffer.asUint8List();
        update();
      });
    });
    SyncCachedNetworkImage(url: resources.last.url ?? '').getImage().then((value) {
      resultSize = Size(value.image.width.toDouble(), value.image.height.toDouble());
      update();
      value.image.toByteData(format: ImageByteFormat.png).then((value) {
        resultData = value!.buffer.asUint8List();
        update();
      });
    });
  }
}

class OptItem {
  HomeCardType type;
  dynamic data;

  OptItem({required this.type, this.data});
}
