///auto generate code, please do not modify;
enum MsgType {
  notice,
  effect,
  comment,
  UNDEFINED,
}

class MsgTypeUtils {
  static MsgType build(String? value) {
    switch (value) {
      case 'notice':
        return MsgType.notice;
      case 'effect':
        return MsgType.effect;
      case 'comment':
        return MsgType.comment;
      default:
        return MsgType.UNDEFINED;
    }
  }
}

extension MsgTypeEx on MsgType {
  value() {
    switch (this) {
      case MsgType.notice:
        return 'notice';
      case MsgType.effect:
        return 'effect';
      case MsgType.comment:
        return 'comment';
      case MsgType.UNDEFINED:
        return null;
    }
  }
}

