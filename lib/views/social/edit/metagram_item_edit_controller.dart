import 'dart:convert';
import 'dart:io';

import 'package:cartoonizer/Common/Extension.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/image/sync_image_provider.dart';
import 'package:cartoonizer/api/cartoonizer_api.dart';
import 'package:cartoonizer/api/downloader.dart';
import 'package:cartoonizer/api/uploader.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/models/EffectModel.dart';
import 'package:cartoonizer/models/discovery_list_entity.dart';
import 'package:cartoonizer/models/enums/account_limit_type.dart';
import 'package:cartoonizer/models/enums/home_card_type.dart';
import 'package:cartoonizer/models/metagram_page_entity.dart';
import 'package:cartoonizer/network/base_requester.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:cartoonizer/views/ai/anotherme/another_me_controller.dart';
import 'package:common_utils/common_utils.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:path/path.dart' as path;

class MetagramItemEditController extends GetxController {
  MetagramItemEntity entity;
  CacheManager cacheManager = AppDelegate().getManager();
  List<List<DiscoveryResource>> items = [];
  List<DiscoveryResource> resources = [];
  int _resourceIndex = 0;

  File? originFile;
  File? resultFile;
  File? transResult;
  bool _showOrigin = false;
  late HomeCardType currentType;
  bool isSelf;

  set showOrigin(bool value) {
    _showOrigin = value;
    update();
  }

  bool get showOrigin => _showOrigin;

  List<OptItem> optList = [
    OptItem(type: HomeCardType.anotherme),
  ];

  String? _error;

  bool error() => _error != null;

  onError() {
    _error = '';
    update();
  }

  onSuccess() {
    _error = null;
    update();
  }

  String? _transKey;

  String? get transKey => _transKey;

  set transKey(String? key) {
    _transKey = key;
  }

  clearTransKey() {
    _transKey = null;
    _error = null;
    update();
  }

  late Uploader api;
  late CartoonizerApi cartoonizerApi;
  int? _mFaceRatio;

  MetagramItemEditController({
    required this.entity,
    required this.items,
    required int index,
    required this.isSelf,
    EffectModel? fullBody,
  }) {
    _resourceIndex = index;
    resources = items[index];
    if (fullBody != null) {
      optList.add(OptItem(type: HomeCardType.cartoonize, data: fullBody));
    }
  }

  @override
  void onInit() {
    super.onInit();
    currentType = HomeCardTypeUtils.build(entity.category);
    entity.category;
    api = Uploader().bindController(this);
    cartoonizerApi = CartoonizerApi().bindController(this);

    var originMd5 = EncryptUtil.encodeMd5(resources.last.url ?? '');
    var resultMd5 = EncryptUtil.encodeMd5(resources.first.url ?? '');
    var imageDir = cacheManager.storageOperator.imageDir;
    var originPath = imageDir.path + originMd5;
    var resultPath = imageDir.path + resultMd5;
    var origin = File(originPath);
    if (origin.existsSync()) {
      originFile = origin;
    }
    var result = File(resultPath);
    if (result.existsSync()) {
      resultFile = result;
    }
  }

  @override
  void onReady() {
    super.onReady();

    var imageDir = cacheManager.storageOperator.imageDir;
    if (originFile == null) {
      var originMd5 = EncryptUtil.encodeMd5(resources.last.url ?? '');
      var originPath = imageDir.path + originMd5;
      Downloader.instance.download(resources.last.url ?? '', originPath).then((value) {
        Downloader.instance.subscribe(
            value,
            DownloadListener(
                onChanged: (count, total) {},
                onError: (error) {
                  originFile = null;
                  update();
                },
                onFinished: (File file) {
                  originFile = file;
                  update();
                }));
      });
    }
    if (resultFile == null) {
      var resultMd5 = EncryptUtil.encodeMd5(resources.first.url ?? '');
      var resultPath = imageDir.path + resultMd5;
      Downloader.instance.download(resources.first.url ?? '', resultPath).then((value) {
        Downloader.instance.subscribe(
            value,
            DownloadListener(
                onChanged: (count, total) {},
                onError: (error) {
                  resultFile = null;
                  update();
                },
                onFinished: (File file) {
                  resultFile = file;
                  update();
                }));
      });
    }
  }

  @override
  void dispose() {
    api.unbind();
    cartoonizerApi.unbind();
    super.dispose();
  }

  Future<TransferResult?> startTransfer() async {
    if (originFile == null) {
      CommonExtension().showToast('Oops failed, please retry a few later');
      return null;
    }
    var metaverseLimitEntity = await cartoonizerApi.getMetaverseLimit();
    if (metaverseLimitEntity != null) {
      if (metaverseLimitEntity.usedCount >= metaverseLimitEntity.dailyLimit) {
        if (AppDelegate.instance.getManager<UserManager>().isNeedLogin) {
          return TransferResult()..type = AccountLimitType.guest;
        } else if (isVip()) {
          return TransferResult()..type = AccountLimitType.vip;
        } else {
          return TransferResult()..type = AccountLimitType.normal;
        }
      }
    }
    if (_mFaceRatio == null) {
      int faceRatio = 0;
      ImageInfo sourceImage = await SyncFileImage(file: originFile!).getImage();
      var totalArea = sourceImage.image.width * sourceImage.image.height;
      FaceDetector detector = FaceDetector(options: FaceDetectorOptions());
      var list = await detector.processImage(InputImage.fromFile(originFile!));
      int maxFaceArea = 0;
      list.forEach((element) {
        var area = element.boundingBox.width * element.boundingBox.height;
        if (area > maxFaceArea) {
          maxFaceArea = area.toInt();
        }
      });
      detector.close();
      if (maxFaceArea != 0) {
        faceRatio = (totalArea / maxFaceArea).round();
      }
      _mFaceRatio = faceRatio;
    }
    var imageUrl = resources.last.url!;
    var baseEntity = await api.generateAnotherMe(imageUrl, _mFaceRatio!, null);
    if (baseEntity == null) {
      return null;
    }
    if (baseEntity.images.isEmpty) {
      return null;
    }
    var image = baseEntity.images.first;
    var key = EncryptUtil.encodeMd5(image);
    var imageUint8List = base64Decode(image);
    var storageOperator = AppDelegate.instance.getManager<CacheManager>().storageOperator;
    var name = storageOperator.recordMetaverseDir.path + key + '.png';
    await File(name).writeAsBytes(imageUint8List.toList(), flush: true);
    _transKey = name;
    transResult = File(_transKey!);
    CartoonizerApi().logAnotherMe({
      'init_images': [imageUrl],
      'face_ratio': _mFaceRatio,
      'result_id': baseEntity.s,
    });
    return TransferResult()..entity = baseEntity;
  }

  Future<BaseEntity?> updateResult() async {
    if (TextUtil.isEmpty(transKey)) {
      return null;
    }
    var uploaded = await uploadFile(transKey!);
    if (uploaded == null) {
      return null;
    }
    items[_resourceIndex].first.url = uploaded.key;
    var resources = jsonEncode(flatItems(items).map((e) => e.toJson()).toList());
    var baseEntity = await cartoonizerApi.updateMetagram(entity.id!, resources);
    if (baseEntity != null) {
      entity.resources = resources;
    }
    return baseEntity;
  }

  Future<MapEntry<String, BaseEntity>?> uploadFile(String filePath) async {
    String b_name = "fast-socialbook";
    String f_name = path.basename(filePath);
    var fileType = f_name.substring(f_name.lastIndexOf(".") + 1);
    if (TextUtil.isEmpty(fileType)) {
      fileType = '*';
    }
    String c_type = "image/$fileType";
    final params = {
      "bucket": b_name,
      "file_name": f_name,
      "content_type": c_type,
    };
    var url = await cartoonizerApi.getPresignedUrl(params);
    if (url == null) {
      return null;
    }
    var baseEntity = await Uploader().uploadFile(url, File(filePath), c_type);
    if (baseEntity != null) {
      return MapEntry(url.split("?")[0], baseEntity);
    } else {
      return null;
    }
  }

  List<DiscoveryResource> flatItems(List<List<DiscoveryResource>> items) {
    List<DiscoveryResource> result = [];
    items.forEach((element) {
      result.addAll(element);
    });
    return result;
  }
}

class OptItem {
  HomeCardType type;
  dynamic data;

  OptItem({required this.type, this.data});
}
