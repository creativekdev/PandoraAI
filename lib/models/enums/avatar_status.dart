///auto generate code, please do not modify;
enum AvatarStatus {
  pending,
  processing,
  completed,
  subscribed,
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
    }
  }
}

