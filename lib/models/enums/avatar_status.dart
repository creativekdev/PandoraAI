import 'package:cartoonizer/Common/importFile.dart';

///auto generate code, please do not modify;
enum AvatarStatus {
  pending,
  processing,
  completed,
  subscribed,
  bought,
  UNDEFINED,
}

class AvatarStatusUtils {
  static AvatarStatus build(String? value) {
    switch (value) {
      case 'pending':
        return AvatarStatus.pending;
      case 'processing':
        return AvatarStatus.processing;
      case 'subscribed':
        return AvatarStatus.subscribed;
      case 'completed':
        return AvatarStatus.completed;
      case 'bought':
        return AvatarStatus.bought;
      default:
        return AvatarStatus.UNDEFINED;
    }
  }
}

extension AvatarStatusEx on AvatarStatus {
  value() {
    switch (this) {
      case AvatarStatus.pending:
        return 'pending';
      case AvatarStatus.processing:
        return 'processing';
      case AvatarStatus.subscribed:
        return 'subscribed';
      case AvatarStatus.completed:
        return 'completed';
      case AvatarStatus.UNDEFINED:
        return null;
      case AvatarStatus.bought:
        return 'bought';
    }
  }

  title(BuildContext context) {
    switch (this) {
      case AvatarStatus.pending:
      case AvatarStatus.processing:
        return S.of(context).waiting;
      case AvatarStatus.completed:
      case AvatarStatus.subscribed:
        return S.of(context).created;
      case AvatarStatus.UNDEFINED:
        return S.of(context).all;
      case AvatarStatus.bought:
        return S.of(context).bought;
    }
  }
}
