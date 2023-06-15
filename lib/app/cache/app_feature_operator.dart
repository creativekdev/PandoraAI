import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Controller/effect_data_controller.dart';
import 'package:cartoonizer/Widgets/cacheImage/cached_network_image_utils.dart';
import 'package:cartoonizer/Widgets/router/routers.dart';
import 'package:cartoonizer/generated/json/base/json_convert_content.dart';
import 'package:cartoonizer/models/app_feature_entity.dart';
import 'package:cartoonizer/models/enums/home_card_type.dart';
import 'package:cartoonizer/views/ai/anotherme/anotherme.dart';
import 'package:cartoonizer/views/ai/avatar/avatar.dart';
import 'package:cartoonizer/views/ai/drawable/ai_drawable.dart';
import 'package:cartoonizer/views/ai/txt2img/txt2img.dart';
import 'package:cartoonizer/views/social/metagram.dart';
import 'package:cartoonizer/views/transfer/cartoonizer/cartoonize.dart';
import 'package:cartoonizer/views/transfer/style_morph/style_morph.dart';
import 'package:common_utils/common_utils.dart';

import 'cache_manager.dart';

class AppFeatureOperator {
  CacheManager cacheManager;

  AppFeatureEntity? get _appFeature {
    var json = cacheManager.getJson(CacheManager.lastAppFeature);
    if (json == null) {
      return null;
    }
    return jsonConvert.convert<AppFeatureEntity>(json);
  }

  AppFeatureOperator({required this.cacheManager});

  Future<void> refreshFeature(AppFeatureEntity? entity) async {
    if (entity == null) {
      return;
    }
    var newSign = EncryptUtil.encodeMd5(entity.toString());
    var oldSign = cacheManager.getString(CacheManager.lastShownFeatureSign);
    if (newSign != oldSign) {
      cacheManager.setJson(CacheManager.lastAppFeature, entity.toJson());
    }
  }

  Future<bool> judgeAndOpenFeaturePage(BuildContext context) async {
    var feature = _appFeature;
    if (feature == null) {
      return false;
    }
    var oldSign = cacheManager.getString(CacheManager.lastShownFeatureSign);
    var newSign = EncryptUtil.encodeMd5(feature.toString());
    if (oldSign == newSign) {
      return false;
    }
    var result = await Navigator.of(context).push<bool>(Bottom2TopRouter(
        child: AppFeaturePage(
      entity: feature,
    )));
    cacheManager.setString(CacheManager.lastShownFeatureSign, newSign);

    if (result ?? false) {
      HomeCardTypeUtils.jump(context: context, source: 'in_app_messaging', payload: feature.feature());
      return true;
    }
    return false;
  }
}

class AppFeaturePage extends StatefulWidget {
  AppFeatureEntity entity;

  AppFeaturePage({
    Key? key,
    required this.entity,
  }) : super(key: key);

  @override
  State<AppFeaturePage> createState() => _AppFeaturePageState();
}

class _AppFeaturePageState extends State<AppFeaturePage> {
  late AppFeatureEntity entity;
  AppFeaturePayload? feature;
  late HomeCardType type;

  @override
  void initState() {
    super.initState();
    entity = widget.entity;
    feature = entity.feature();
    type = HomeCardTypeUtils.build(feature?.target ?? '');
  }

  @override
  Widget build(BuildContext context) {
    if (feature?.image == null) {
      return Container();
    }
    return Stack(
      children: [
        CachedNetworkImageUtils.custom(
          context: context,
          imageUrl: entity.feature()!.image!,
          width: ScreenUtil.screenSize.width,
          height: ScreenUtil.screenSize.height,
          fit: BoxFit.cover,
        ),
        Positioned(
          top: ScreenUtil.getStatusBarHeight() + $(4),
          right: $(4),
          child: Icon(
            Icons.close,
            color: Colors.white,
            size: $(22),
          ).intoContainer(padding: EdgeInsets.all($(12))).intoGestureDetector(onTap: () {
            Navigator.of(context).pop();
          }),
        ),
        Positioned(
          child: Text(
            type == HomeCardType.UNDEFINED ? S.of(context).ok : S.of(context).try_it_now,
            style: TextStyle(
              color: ColorConstant.White,
              fontSize: $(18),
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
            ),
          )
              .intoContainer(
                  padding: EdgeInsets.symmetric(vertical: $(10)),
                  alignment: Alignment.center,
                  width: double.maxFinite,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular($(8)),
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF243CFF),
                        Color(0xFFE31ECD),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ))
              .intoGestureDetector(onTap: () {
            Navigator.of(context).pop(true);
          }),
          left: $(35),
          right: $(35),
          bottom: ScreenUtil.getBottomPadding(context) + $(40),
        ),
      ],
    ).intoMaterial(
      color: Colors.transparent,
    );
  }
}
