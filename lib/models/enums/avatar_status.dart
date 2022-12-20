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

  title() {
    switch (this) {
      case AvatarStatus.pending:
      case AvatarStatus.processing:
        return 'Waiting';
      case AvatarStatus.completed:
      case AvatarStatus.subscribed:
        return 'Created';
      case AvatarStatus.UNDEFINED:
        return 'All';
      case AvatarStatus.bought:
        return 'Bought';
    }
  }
}
