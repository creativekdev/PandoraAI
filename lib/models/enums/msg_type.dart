///auto generate code, please do not modify;
enum MsgType {
  comment_social_post,
  comment_social_post_comment,
  like_social_post,
  like_social_post_comment,
  UNDEFINED,
}

class MsgTypeUtils {
  static MsgType build(String? value) {
    switch (value) {
      case 'comment_social_post':
        return MsgType.comment_social_post;
      case 'comment_social_post_comment':
        return MsgType.comment_social_post_comment;
      case 'like_social_post':
        return MsgType.like_social_post;
      case 'like_social_post_comment':
        return MsgType.like_social_post_comment;
      default:
        return MsgType.UNDEFINED;
    }
  }
}

extension MsgTypeEx on MsgType {
  value() {
    switch (this) {
      case MsgType.comment_social_post:
        return 'comment_social_post';
      case MsgType.comment_social_post_comment:
        return 'comment_social_post_comment';
      case MsgType.like_social_post:
        return 'like_social_post';
      case MsgType.like_social_post_comment:
        return 'like_social_post_comment';
      case MsgType.UNDEFINED:
        return null;
    }
  }
}
