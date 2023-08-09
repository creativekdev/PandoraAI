import 'dart:convert';

import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Controller/effect_data_controller.dart';
import 'package:cartoonizer/Widgets/webview/app_web_view.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/common/Extension.dart';
import 'package:cartoonizer/models/app_feature_entity.dart';
import 'package:cartoonizer/models/discovery_list_entity.dart';
import 'package:cartoonizer/models/enums/image_edition_function.dart';
import 'package:cartoonizer/models/home_page_entity.dart';
import 'package:cartoonizer/views/ai/anotherme/anotherme.dart';
import 'package:cartoonizer/views/ai/avatar/avatar.dart';
import 'package:cartoonizer/views/ai/drawable/colorfill/ai_coloring.dart';
import 'package:cartoonizer/views/ai/drawable/scribble/ai_drawable.dart';
import 'package:cartoonizer/views/ai/edition/image_edition.dart';
import 'package:cartoonizer/views/ai/txt2img/txt2img.dart';
import 'package:cartoonizer/views/ai/txt2img/txt2img_screen.dart';
import 'package:cartoonizer/views/common/video_preview_screen.dart';
import 'package:cartoonizer/views/mine/filter/im_filter.dart';
import 'package:cartoonizer/views/social/metagram.dart';
import 'package:cartoonizer/views/transfer/cartoonizer/cartoonize.dart';
import 'package:cartoonizer/views/transfer/controller/all_transfer_controller.dart';
import 'package:cartoonizer/views/transfer/style_morph/style_morph.dart';
import 'package:common_utils/common_utils.dart';

///auto generate code, please do not modify;
enum HomeCardType {
  cartoonize,
  anotherme,
  ai_avatar,
  txt2img,
  scribble,
  metagram,
  stylemorph,
  lineart,
  UNDEFINED,
  removeBg,
  nothing,
  imageEdition,
  url,
}

class HomeCardTypeUtils {
  static HomeCardType build(String? value) {
    switch (value) {
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
        return HomeCardType.stylemorph;
      case 'lineart':
        return HomeCardType.lineart;
      case 'removebg':
        return HomeCardType.removeBg;
      case '':
      case null:
        return HomeCardType.nothing;
      case 'url':
        return HomeCardType.url;
      case 'image_edition':
        return HomeCardType.imageEdition;
      default:
        return HomeCardType.UNDEFINED;
    }
  }

  static jump({
    required BuildContext context,
    required String source,
    AppFeaturePayload? payload,
    DiscoveryListEntity? data,
    HomePageHomepageTools? homeData,
  }) {
    if (payload != null) {
      var target = HomeCardTypeUtils.build(payload.target ?? '');
      if (target == HomeCardType.url) {
        AppWebView.open(context, url: payload.data!, source: source);
      } else {
        List<String?> split = payload.data?.split(',') ?? [null];
        jumpWithHomeType(context, source, target, initKey: split.last);
      }
    } else if (data != null) {
      var target = data.category;
      String? initKey;
      Txt2imgInitData? txt2imgInitData;
      String style = target.value();
      if (target == HomeCardType.url) {
        var payload = jsonDecode(data.payload!);
        var url = payload['url'].toString();
        AppWebView.open(context, url: url, source: source);
      } else if (target == HomeCardType.cartoonize || target == HomeCardType.stylemorph) {
        initKey = data.cartoonizeKey;
        style = '$style-${initKey}';
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
      if (source == "home_page_new") {
        Events.homeTemplateClick(source: source, style: style);
      } else {
        Events.discoveryTemplateClick(source: source, style: style);
      }
      jumpWithHomeType(context, source, target, initKey: initKey, initData: txt2imgInitData);
    } else if (homeData != null) {
      var target = homeData.category;
      if (target == HomeCardType.url) {
        var payload = jsonDecode(homeData.payload!);
        var url = payload['url'].toString();
        AppWebView.open(context, url: url, source: source);
      } else {
        Txt2imgInitData? txt2imgInitData;
        String style = target.value();
        String? initKey;
        if (target == HomeCardType.cartoonize) {
          if (!TextUtil.isEmpty(homeData.cartoonizeKey)) {
            initKey = homeData.cartoonizeKey;
            EffectDataController effectDataController = Get.find<EffectDataController>();
            if (effectDataController.data == null) {
              return;
            }
            style = '$style-${initKey}';
          }
        } else if (target == HomeCardType.txt2img) {
          Map? payload;
          try {
            payload = json.decode(homeData.payload ?? '');
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
        Events.homeTemplateClick(source: source, style: style);
        jumpWithHomeType(context, source, target, initKey: initKey, initData: txt2imgInitData);
      }
    }
  }

  static jumpWithHomeType(
    BuildContext context,
    String source,
    HomeCardType target, {
    Txt2imgInitData? initData,
    String? initKey,
    String? url,
  }) {
    var action = () {
      var context = Get.context!;
      switch (target) {
        case HomeCardType.url:
          AppWebView.open(context, url: url!, source: source);
          break;
        case HomeCardType.txt2img:
          Txt2img.open(context, source: source, initData: initData);
          break;
        case HomeCardType.anotherme:
          AnotherMe.open(context, source: source);
          break;
        case HomeCardType.cartoonize:
          Cartoonize.open(context, source: source, initKey: initKey);
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
        case HomeCardType.stylemorph:
          StyleMorph.open(context, source, initKey: initKey);
          break;
        case HomeCardType.lineart:
          AiColoring.open(context, source: source);
          break;
        case HomeCardType.UNDEFINED:
          CommonExtension().showToast(S.of(context).oldversion_tips);
          break;
        case HomeCardType.removeBg:
          ImageEdition.open(context, source: source, style: EffectStyle.No, function: ImageEditionFunction.removeBg);
          break;
        case HomeCardType.nothing:
          //do nothing
          break;
        case HomeCardType.imageEdition:
          ImageEdition.open(context, source: source, style: EffectStyle.All, function: ImageEditionFunction.filter);
          break;
      }
    };
    EffectDataController dataController = Get.find();
    var pick = dataController.data!.homeCards.pick((t) => t.type == target.value());
    if (!TextUtil.isEmpty(pick?.tutorial)) {
      CacheManager cacheManager = AppDelegate.instance.getManager();
      var key = EncryptUtil.encodeMd5(pick!.tutorial!);
      var bool = cacheManager.getBool('${CacheManager.viewPreviewOpen}:$key');
      if (bool) {
        action.call();
      } else {
        Navigator.of(context)
            .push(MaterialPageRoute(
          settings: RouteSettings(name: '/ViewPreviewScreen'),
          builder: (_) => ViewPreviewScreen(
            url: pick.tutorial!,
            title: target.title(),
            description: target.description(),
          ),
        ))
            .then((value) {
          if (value == true) {
            cacheManager.setBool('${CacheManager.viewPreviewOpen}:$key', true);
            delay(() => action.call());
          }
        });
      }
    } else {
      action.call();
    }
  }
}

extension HomeCardTypeEx on HomeCardType {
  value() {
    switch (this) {
      case HomeCardType.cartoonize:
        return 'cartoonize';
      case HomeCardType.anotherme:
        return 'anotherme';
      case HomeCardType.ai_avatar:
        return 'ai_avatar';
      case HomeCardType.txt2img:
        return 'txt2img';
      case HomeCardType.UNDEFINED:
        return 'undefined';
      case HomeCardType.scribble:
        return 'scribble';
      case HomeCardType.metagram:
        return 'metagram';
      case HomeCardType.stylemorph:
        return 'stylemorph';
      case HomeCardType.lineart:
        return 'lineart';
      case HomeCardType.removeBg:
        return 'removeBg';
      case HomeCardType.nothing:
      case HomeCardType.url:
        return '';
      case HomeCardType.imageEdition:
        return 'image_edition';
    }
  }

  description() {
    switch (this) {
      case HomeCardType.lineart:
        return 'Upload a sketch picture to generate a colorful AI artwork';
      default:
        return '';
    }
  }

  String title() {
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
        return 'Text to Image';
      case HomeCardType.scribble:
        return 'AI Scribble';
      case HomeCardType.metagram:
        return 'Metagram';
      case HomeCardType.stylemorph:
        return 'Style Morph';
      case HomeCardType.lineart:
        return 'AI Coloring';
      case HomeCardType.removeBg:
        return 'Bg Remover';
      case HomeCardType.nothing:
      case HomeCardType.url:
        return '';
      case HomeCardType.imageEdition:
        return 'Image Edition';
    }
  }

  String tagTitle() {
    switch (this) {
      case HomeCardType.cartoonize:
        return '# Facetoon';
      case HomeCardType.anotherme:
        return '# Me-Taverse';
      case HomeCardType.ai_avatar:
        return '# AIAvatar';
      case HomeCardType.txt2img:
        return '# AITextToImage';
      case HomeCardType.scribble:
        return '# AIScribble';
      case HomeCardType.metagram:
        return '# Metagram';
      case HomeCardType.stylemorph:
        return '# StyleMorph';
      case HomeCardType.lineart:
        return '# AIColoring';
      case HomeCardType.UNDEFINED:
        return '';
      case HomeCardType.removeBg:
        return '# RemoveBG';
      case HomeCardType.nothing:
        return '';
      case HomeCardType.url:
        return '';
      case HomeCardType.imageEdition:
        return '# ImageEdition';
    }
  }
}
