import 'package:cartoonizer/images-res.dart';

///auto generate code, please do not modify;
enum ConnectorPlatform {
  youtube,
  facebook,
  instagram,
  instagramBusiness,
  tiktok,
  UNDEFINED,
}

class ConnectorPlatformUtils {
  static ConnectorPlatform build(String? value) {
    switch (value) {
      case 'youtube':
        return ConnectorPlatform.youtube;
      case 'facebook':
        return ConnectorPlatform.facebook;
      case 'instagram':
        return ConnectorPlatform.instagram;
      case 'instagramBusiness':
        return ConnectorPlatform.instagramBusiness;
      case 'tiktok':
        return ConnectorPlatform.tiktok;
      default:
        return ConnectorPlatform.UNDEFINED;
    }
  }
}

extension ConnectorPlatformEx on ConnectorPlatform {
  String? title() {
    switch (this) {
      case ConnectorPlatform.youtube:
        return 'Continue with YouTube';
      case ConnectorPlatform.facebook:
        return 'Continue with IG Business';
      case ConnectorPlatform.instagram:
      case ConnectorPlatform.instagramBusiness:
        return 'Continue with Instagram';
      case ConnectorPlatform.tiktok:
        return 'Continue with TikTok';
      case ConnectorPlatform.UNDEFINED:
        return null;
    }
  }

  String? image() {
    switch (this) {
      case ConnectorPlatform.youtube:
        return Images.ic_sign_youtube;
      case ConnectorPlatform.facebook:
        return Images.ic_facebook;
      case ConnectorPlatform.instagram:
      case ConnectorPlatform.instagramBusiness:
        return Images.ic_sign_instagram;
      case ConnectorPlatform.tiktok:
        return Images.ic_sign_tiktok;
      case ConnectorPlatform.UNDEFINED:
        return null;
    }
  }

  String? value() {
    switch (this) {
      case ConnectorPlatform.youtube:
        return 'youtube';
      case ConnectorPlatform.facebook:
        return 'facebook';
      case ConnectorPlatform.instagram:
        return 'instagram';
      case ConnectorPlatform.instagramBusiness:
        return 'instagramBusiness';
      case ConnectorPlatform.tiktok:
        return 'tiktok';
      case ConnectorPlatform.UNDEFINED:
        return null;
    }
  }

  String? route() {
    switch (this) {
      case ConnectorPlatform.youtube:
        return '/oauth/youtube';
      case ConnectorPlatform.facebook:
        return '/';
      case ConnectorPlatform.instagram:
        return '/oauth/instagram_v2';
      case ConnectorPlatform.tiktok:
        return '/oauth/tiktok';
      case ConnectorPlatform.UNDEFINED:
        return null;
      case ConnectorPlatform.instagramBusiness:
        return '/oauth/instagram_business';
    }
  }
}
