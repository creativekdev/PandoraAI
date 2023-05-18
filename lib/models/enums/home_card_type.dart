///auto generate code, please do not modify;
enum HomeCardType {
  cartoonize,
  anotherme,
  ai_avatar,
  text2image,
  scribble,
  UNDEFINED,
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
        return HomeCardType.text2image;
      case 'scribble':
        return HomeCardType.scribble;
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
      case HomeCardType.text2image:
        return 'txt2img';
      case HomeCardType.UNDEFINED:
        return null;
      case HomeCardType.scribble:
        return 'scribble';
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
      case HomeCardType.text2image:
        return 'AI Artist: Text to Image';
      case HomeCardType.scribble:
        return 'AI Scribble';
    }
  }
}
