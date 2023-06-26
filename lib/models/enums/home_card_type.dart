import 'dart:convert';

import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Controller/effect_data_controller.dart';
import 'package:cartoonizer/common/Extension.dart';
import 'package:cartoonizer/models/api_config_entity.dart';
import 'package:cartoonizer/models/app_feature_entity.dart';
import 'package:cartoonizer/models/discovery_list_entity.dart';
import 'package:cartoonizer/views/ai/anotherme/anotherme.dart';
import 'package:cartoonizer/views/ai/avatar/avatar.dart';
import 'package:cartoonizer/views/ai/drawable/colorfill/ai_coloring.dart';
import 'package:cartoonizer/views/ai/drawable/scribble/ai_drawable.dart';
import 'package:cartoonizer/views/ai/txt2img/txt2img.dart';
import 'package:cartoonizer/views/ai/txt2img/txt2img_screen.dart';
import 'package:cartoonizer/views/social/metagram.dart';
import 'package:cartoonizer/views/transfer/cartoonizer/cartoonize.dart';
import 'package:cartoonizer/views/transfer/style_morph/style_morph.dart';

///auto generate code, please do not modify;
enum HomeCardType {
  cartoonize,
  anotherme,
  ai_avatar,
  txt2img,
  scribble,
  metagram,
  style_morph,
  lineart,
  UNDEFINED,
}

class HomeCardTypeUtils {
  static HomeCardType build(String? value) {
    switch (value?.toLowerCase()) {
      case 'cartoonize':
        return HomeCardType.cartoonize;
      case 'anotherme':
      case 'another_me':
        return HomeCardType.anotherme;
      case 'ai_avatar':
        return HomeCardType.ai_avatar;
      case 'txt2img':
        return HomeCardType.txt2img;
      case 'scribble':
        return HomeCardType.scribble;
      case 'metagram':
        return HomeCardType.metagram;
      case 'stylemorph':
      case 'style_morph':
        return HomeCardType.style_morph;
      case 'lineart':
        return HomeCardType.lineart;
      default:
        return HomeCardType.UNDEFINED;
    }
  }

  static jump({
    required BuildContext context,
    required String source,
    AppFeaturePayload? payload,
    DiscoveryListEntity? data,
  }) {
    if (payload != null) {
      var target = HomeCardTypeUtils.build(payload.target ?? '');
      var split = payload.data?.split(',');
      InitPos pos = InitPos();
      if (split != null && split.length >= 2) {
        var controller = Get.find<EffectDataController>();
        pos = controller.findItemPos(split[0], split[1], split.length > 2 ? split[2] : null);
      }
      jumpWithHomeType(context, source, target, pos);
    } else if (data != null) {
      var target = build(data.category);
      InitPos initPos = InitPos();
      Txt2imgInitData? txt2imgInitData;
      String style = target.value();
      if (target == HomeCardType.cartoonize) {
        EffectDataController effectDataController = Get.find<EffectDataController>();
        if (effectDataController.data == null) {
          return;
        }
        String key = data.cartoonizeKey;
        int tabPos = effectDataController.data!.tabPos(key);
        int categoryPos = 0;
        int itemPos = 0;
        if (tabPos == -1) {
          CommonExtension().showToast(S.of(context).template_not_available);
          return;
        }
        EffectCategory effectModel = effectDataController.data!.findCategory(key)!;
        EffectItem effectItem = effectModel.effects.pick((t) => t.key == key)!;
        categoryPos = effectDataController.tabTitleList.findPosition((data) => data.categoryKey == effectModel.key)!;
        itemPos = effectDataController.tabItemList.findPosition((data) => data.data.key == effectItem.key)!;
        initPos = InitPos()
          ..categoryPos = categoryPos
          ..itemPos = itemPos
          ..tabPos = tabPos;
        style = '$style-${effectItem.key}';
      } else if (target == HomeCardType.txt2img) {
        Map? payload;
        try {
          payload = json.decode(data.payload ?? '');
        } catch (e) {}
        if (payload != null && payload['txt2img_params'] != null) {
          var params = payload['txt2img_params'];
          int width = params['width'] ?? 512;
          int height = params['height'] ?? 512;
          txt2imgInitData = Txt2imgInitData()
            ..prompt = params['prompt']
            ..width = width
            ..height = height;
        }
      }
      Events.discoveryTemplateClick(source: source, style: style);
      jumpWithHomeType(context, source, target, initPos, initData: txt2imgInitData);
    }
  }

  static jumpWithHomeType(
    BuildContext context,
    String source,
    HomeCardType target,
    InitPos pos, {
    Txt2imgInitData? initData,
  }) {
    switch (target) {
      case HomeCardType.txt2img:
        Txt2img.open(context, source: source, initData: initData);
        break;
      case HomeCardType.anotherme:
        AnotherMe.open(context, source: source);
        break;
      case HomeCardType.cartoonize:
        Cartoonize.open(context, source: source, tabPos: pos.itemPos, categoryPos: pos.categoryPos, itemPos: pos.itemPos);
        break;
      case HomeCardType.ai_avatar:
        Avatar.open(context, source: source);
        break;
      case HomeCardType.scribble:
        AiDrawable.open(context, source: source);
        break;
      case HomeCardType.metagram:
        Metagram.openBySelf(context, source: source);
        break;
      case HomeCardType.style_morph:
        StyleMorph.open(context, source);
        break;
      case HomeCardType.UNDEFINED:
        CommonExtension().showToast(S.of(context).oldversion_tips);
        break;
      case HomeCardType.lineart:
        AiColoring.open(context, source: source);
        break;
    }
  }
}

extension HomeCardTypeEx on HomeCardType {
  value() {
    switch (this) {
      case HomeCardType.cartoonize:
        return 'cartoonize';
      case HomeCardType.anotherme:
        return 'another_me';
      case HomeCardType.ai_avatar:
        return 'ai_avatar';
      case HomeCardType.txt2img:
        return 'txt2img';
      case HomeCardType.UNDEFINED:
        return '';
      case HomeCardType.scribble:
        return 'scribble';
      case HomeCardType.metagram:
        return 'metagram';
      case HomeCardType.style_morph:
        return 'stylemorph';
      case HomeCardType.lineart:
        return 'lineart';
    }
  }

  title() {
    switch (this) {
      case HomeCardType.cartoonize:
        return 'Facetoon';
      case HomeCardType.anotherme:
        return 'Me-taverse';
      case HomeCardType.ai_avatar:
        return 'Pandora Avatar';
      case HomeCardType.UNDEFINED:
        return '';
      case HomeCardType.txt2img:
        return 'AI Artist: Text to Image';
      case HomeCardType.scribble:
        return 'AI Scribble';
      case HomeCardType.metagram:
        return 'Metagram';
      case HomeCardType.style_morph:
        return 'Style Morph';
      case HomeCardType.lineart:
        return 'AI Coloring';
    }
  }
}
