///auto generate code, please do not modify;
enum HomeCardType {
  cartoonize,
  anotherme,
  ai_avatar,
  txt2img,
  scribble,
  metagram,
  style_morph,
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
      case 'style_morph':
        return HomeCardType.style_morph;
      default:
        return HomeCardType.UNDEFINED;
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
        return null;
      case HomeCardType.scribble:
        return 'scribble';
      case HomeCardType.metagram:
        return 'metagram';
      case HomeCardType.style_morph:
        return 'style_morph';
    }
  }

  title() {
    switch (this) {
      case HomeCardType.cartoonize:
        return 'Facetoon';
      case HomeCardType.anotherme:
        return 'Me-Taverse';
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
    }
  }
}
