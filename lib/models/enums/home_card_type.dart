///auto generate code, please do not modify;
enum HomeCardType {
  cartoonize,
  anotherme,
  ai_avatar,
  UNDEFINED,
}

class HomeCardTypeUtils {
  static HomeCardType build(String? value) {
    switch (value) {
      case 'cartoonize':
        return HomeCardType.cartoonize;
      case 'anotherme':
        return HomeCardType.anotherme;
      case 'ai_avatar':
        return HomeCardType.ai_avatar;
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
        return 'anotherme';
      case HomeCardType.ai_avatar:
        return 'ai_avatar';
      case HomeCardType.UNDEFINED:
        return null;
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
    }
  }
}