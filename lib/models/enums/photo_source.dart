import 'package:cartoonizer/common/importFile.dart';

///auto generate code, please do not modify;
enum PhotoSource {
  recent,
  album,
  albumFace,
  UNDEFINED,
}

class PhotoSourceUtils {
  static PhotoSource build(String? value) {
    switch (value) {
      case 'recent':
        return PhotoSource.recent;
      case 'album':
        return PhotoSource.album;
      case 'albumFace':
        return PhotoSource.albumFace;
      default:
        return PhotoSource.UNDEFINED;
    }
  }
}

extension PhotoSourceEx on PhotoSource {
  title(BuildContext context) {
    switch (this) {
      case PhotoSource.recent:
        return S.of(context).recent;
      case PhotoSource.album:
        return S.of(context).others;
      case PhotoSource.albumFace:
        return S.of(context).faces;
      case PhotoSource.UNDEFINED:
        return null;
    }
  }

  value() {
    switch (this) {
      case PhotoSource.recent:
        return 'recent';
      case PhotoSource.album:
        return 'album';
      case PhotoSource.albumFace:
        return 'album_face';
      case PhotoSource.UNDEFINED:
        return null;
    }
  }

  bool isAiSource() => this == PhotoSource.album || this == PhotoSource.albumFace;
}
