import 'dart:math' as math;

class SensorHelper {
  /// calculate pose of people by accelerometer from device's sensor.
  static PoseState? getPose(double x, double y, double z) {
    if (x.abs() < 6) {
      if (y < -6) {
        return PoseState.headstand;
      }
      if (y > 6) {
        return PoseState.stand;
      }
    }
    if (x > 6) {
      return PoseState.leftDumped;
    }
    if (x < -6) {
      return PoseState.rightDumped;
    }
    return null;
  }
}

/// screen direction
enum PoseState {
  stand, // stand
  leftDumped, // left dumped
  rightDumped, // right dumped
  headstand, // headstand
}

extension PoseStateEx on PoseState {
  /// get coefficient by pose;
  /// stand -> 0
  /// leftDumped -> 270
  /// rightDumped -> 90
  /// headstand -> 180
  int coefficient() {
    switch (this) {
      case PoseState.stand:
        return 0;
      case PoseState.leftDumped:
        return 270;
      case PoseState.rightDumped:
        return 90;
      case PoseState.headstand:
        return 180;
    }
  }

  /// get show rotate by pose;
  /// stand -> 0
  /// leftDumped -> 90 -pi/2
  /// rightDumped -> -90 pi/2
  /// headstand -> 180 pi
  double rotate() {
    switch (this) {
      case PoseState.stand:
        return 0;
      case PoseState.leftDumped:
        return math.pi / 2;
      case PoseState.rightDumped:
        return -math.pi / 2;
      case PoseState.headstand:
        return math.pi;
    }
  }
}
