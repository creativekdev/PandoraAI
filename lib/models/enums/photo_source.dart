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
  title() {
    switch (this) {
      case PhotoSource.recent:
        return 'Recent';
      case PhotoSource.album:
        return 'Others';
      case PhotoSource.albumFace:
        return 'Faces';
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
