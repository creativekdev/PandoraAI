import 'package:camera/camera.dart';
import 'package:cartoonizer/Common/importFile.dart';

import 'dart:math';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/foundation.dart';

// TODO(stuartmorgan): Remove this once the package requires 2.10, where the
// dart:async `unawaited` accepts a nullable future.
void _unawaited(Future<void>? future) {}

/// Controls a device camera.
///
/// Use [availableCameras] to get a list of available cameras.
///
/// Before using a [CameraController] a call to [initialize] must complete.
///
/// To show the camera preview on the screen use a [CameraPreview] widget.
class CustomCameraController extends ValueNotifier<CameraValue> {
  /// Creates a new camera controller in an uninitialized state.
  CustomCameraController(
    this.description,
    this.resolutionPreset, {
    this.enableAudio = true,
    this.imageFormatGroup,
  }) : super(const CameraValue.uninitialized());

  /// The properties of the camera device controlled by this controller.
  final CameraDescription description;

  /// The resolution this controller is targeting.
  ///
  /// This resolution preset is not guaranteed to be available on the device,
  /// if unavailable a lower resolution will be used.
  ///
  /// See also: [ResolutionPreset].
  final ResolutionPreset resolutionPreset;

  /// Whether to include audio when recording a video.
  final bool enableAudio;

  /// The [ImageFormatGroup] describes the output of the raw image format.
  ///
  /// When null the imageFormat will fallback to the platforms default.
  final ImageFormatGroup? imageFormatGroup;

  /// The id of a camera that hasn't been initialized.
  @visibleForTesting
  static const int kUninitializedCameraId = -1;
  int _cameraId = kUninitializedCameraId;

  bool _isDisposed = false;

  disposed() => _isDisposed;

  StreamSubscription<CameraImageData>? _imageStreamSubscription;
  FutureOr<bool>? _initCalled;
  StreamSubscription<DeviceOrientationChangedEvent>? _deviceOrientationSubscription;

  /// Checks whether [CameraController.dispose] has completed successfully.
  ///
  /// This is a no-op when asserts are disabled.
  void debugCheckIsDisposed() {
    assert(_isDisposed);
  }

  /// The camera identifier with which the controller is associated.
  int get cameraId => _cameraId;

  /// Initializes the camera on the device.
  ///
  /// Throws a [CameraException] if the initialization fails.
  Future<void> initialize() async {
    if (_isDisposed) {
      throw CameraException(
        'Disposed CameraController',
        'initialize was called on a disposed CameraController',
      );
    }
    try {
      final Completer<CameraInitializedEvent> initializeCompleter = Completer<CameraInitializedEvent>();

      _deviceOrientationSubscription = CameraPlatform.instance.onDeviceOrientationChanged().listen((DeviceOrientationChangedEvent event) {
        value = value.copyWith(
          deviceOrientation: event.orientation,
        );
      });

      _cameraId = await CameraPlatform.instance.createCamera(
        description,
        resolutionPreset,
        enableAudio: enableAudio,
      );

      _unawaited(CameraPlatform.instance.onCameraInitialized(_cameraId).first.then((CameraInitializedEvent event) {
        initializeCompleter.complete(event);
      }));

      await CameraPlatform.instance.initializeCamera(
        _cameraId,
        imageFormatGroup: imageFormatGroup ?? ImageFormatGroup.unknown,
      );

      value = value.copyWith(
        isInitialized: true,
        previewSize: await initializeCompleter.future.then((CameraInitializedEvent event) => Size(
              event.previewWidth,
              event.previewHeight,
            )),
        exposureMode: await initializeCompleter.future.then((CameraInitializedEvent event) => event.exposureMode),
        focusMode: await initializeCompleter.future.then((CameraInitializedEvent event) => event.focusMode),
        exposurePointSupported: await initializeCompleter.future.then((CameraInitializedEvent event) => event.exposurePointSupported),
        focusPointSupported: await initializeCompleter.future.then((CameraInitializedEvent event) => event.focusPointSupported),
      );
    } on PlatformException catch (e) {
      throw CameraException(e.code, e.message);
    }

    _initCalled = true;
  }

  /// Prepare the capture session for video recording.
  ///
  /// Use of this method is optional, but it may be called for performance
  /// reasons on iOS.
  ///
  /// Preparing audio can cause a minor delay in the CameraPreview view on iOS.
  /// If video recording is intended, calling this early eliminates this delay
  /// that would otherwise be experienced when video recording is started.
  /// This operation is a no-op on Android and Web.
  ///
  /// Throws a [CameraException] if the prepare fails.
  Future<void> prepareForVideoRecording() async {
    await CameraPlatform.instance.prepareForVideoRecording();
  }

  /// Pauses the current camera preview
  Future<void> pausePreview() async {
    if (value.isPreviewPaused) {
      return;
    }
    try {
      await CameraPlatform.instance.pausePreview(_cameraId);
      value = value.copyWith(isPreviewPaused: true, previewPauseOrientation: value.lockedCaptureOrientation ?? value.deviceOrientation);
    } on PlatformException catch (e) {
      throw CameraException(e.code, e.message);
    }
  }

  /// Resumes the current camera preview
  Future<void> resumePreview() async {
    if (!value.isPreviewPaused) {
      return;
    }
    try {
      await CameraPlatform.instance.resumePreview(_cameraId);
      value = value.copyWith(isPreviewPaused: false);
    } on PlatformException catch (e) {
      throw CameraException(e.code, e.message);
    }
  }

  /// Captures an image and returns the file where it was saved.
  ///
  /// Throws a [CameraException] if the capture fails.
  Future<XFile> takePicture() async {
    _throwIfNotInitialized('takePicture');
    if (value.isTakingPicture) {
      throw CameraException(
        'Previous capture has not returned yet.',
        'takePicture was called before the previous capture returned.',
      );
    }
    try {
      value = value.copyWith(isTakingPicture: true);
      final XFile file = await CameraPlatform.instance.takePicture(_cameraId);
      value = value.copyWith(isTakingPicture: false);
      return file;
    } on PlatformException catch (e) {
      value = value.copyWith(isTakingPicture: false);
      throw CameraException(e.code, e.message);
    }
  }

  /// Start streaming images from platform camera.
  ///
  /// Settings for capturing images on iOS and Android is set to always use the
  /// latest image available from the camera and will drop all other images.
  ///
  /// When running continuously with [CameraPreview] widget, this function runs
  /// best with [ResolutionPreset.low]. Running on [ResolutionPreset.high] can
  /// have significant frame rate drops for [CameraPreview] on lower end
  /// devices.
  ///
  /// Throws a [CameraException] if image streaming or video recording has
  /// already started.
  ///
  /// The `startImageStream` method is only available on Android and iOS (other
  /// platforms won't be supported in current setup).
  ///
  // TODO(bmparr): Add settings for resolution and fps.
  Future<void> startImageStream(onLatestImageAvailable onAvailable) async {
    assert(defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);
    _throwIfNotInitialized('startImageStream');
    if (value.isRecordingVideo) {
      throw CameraException(
        'A video recording is already started.',
        'startImageStream was called while a video is being recorded.',
      );
    }
    if (value.isStreamingImages) {
      throw CameraException(
        'A camera has started streaming images.',
        'startImageStream was called while a camera was streaming images.',
      );
    }

    try {
      _imageStreamSubscription = CameraPlatform.instance.onStreamedFrameAvailable(_cameraId).listen((CameraImageData imageData) {
        onAvailable(CameraImage.fromPlatformInterface(imageData));
      });
      value = value.copyWith(isStreamingImages: true);
    } on PlatformException catch (e) {
      throw CameraException(e.code, e.message);
    }
  }

  /// Stop streaming images from platform camera.
  ///
  /// Throws a [CameraException] if image streaming was not started or video
  /// recording was started.
  ///
  /// The `stopImageStream` method is only available on Android and iOS (other
  /// platforms won't be supported in current setup).
  Future<void> stopImageStream() async {
    assert(defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);
    _throwIfNotInitialized('stopImageStream');
    if (value.isRecordingVideo) {
      throw CameraException(
        'A video recording is already started.',
        'stopImageStream was called while a video is being recorded.',
      );
    }
    if (!value.isStreamingImages) {
      throw CameraException(
        'No camera is streaming images',
        'stopImageStream was called when no camera is streaming images.',
      );
    }

    try {
      value = value.copyWith(isStreamingImages: false);
      await _imageStreamSubscription?.cancel();
      _imageStreamSubscription = null;
    } on PlatformException catch (e) {
      throw CameraException(e.code, e.message);
    }
  }

  /// Start a video recording.
  ///
  /// The video is returned as a [XFile] after calling [stopVideoRecording].
  /// Throws a [CameraException] if the capture fails.
  Future<void> startVideoRecording() async {
    _throwIfNotInitialized('startVideoRecording');
    if (value.isRecordingVideo) {
      throw CameraException(
        'A video recording is already started.',
        'startVideoRecording was called when a recording is already started.',
      );
    }
    if (value.isStreamingImages) {
      throw CameraException(
        'A camera has started streaming images.',
        'startVideoRecording was called while a camera was streaming images.',
      );
    }

    try {
      await CameraPlatform.instance.startVideoRecording(_cameraId);
      value = value.copyWith(isRecordingVideo: true, isRecordingPaused: false, recordingOrientation: value.lockedCaptureOrientation ?? value.deviceOrientation);
    } on PlatformException catch (e) {
      throw CameraException(e.code, e.message);
    }
  }

  /// Stops the video recording and returns the file where it was saved.
  ///
  /// Throws a [CameraException] if the capture failed.
  Future<XFile> stopVideoRecording() async {
    _throwIfNotInitialized('stopVideoRecording');
    if (!value.isRecordingVideo) {
      throw CameraException(
        'No video is recording',
        'stopVideoRecording was called when no video is recording.',
      );
    }
    try {
      final XFile file = await CameraPlatform.instance.stopVideoRecording(_cameraId);
      value = value.copyWith(isRecordingVideo: false);
      return file;
    } on PlatformException catch (e) {
      throw CameraException(e.code, e.message);
    }
  }

  /// Pause video recording.
  ///
  /// This feature is only available on iOS and Android sdk 24+.
  Future<void> pauseVideoRecording() async {
    _throwIfNotInitialized('pauseVideoRecording');
    if (!value.isRecordingVideo) {
      throw CameraException(
        'No video is recording',
        'pauseVideoRecording was called when no video is recording.',
      );
    }
    try {
      await CameraPlatform.instance.pauseVideoRecording(_cameraId);
      value = value.copyWith(isRecordingPaused: true);
    } on PlatformException catch (e) {
      throw CameraException(e.code, e.message);
    }
  }

  /// Resume video recording after pausing.
  ///
  /// This feature is only available on iOS and Android sdk 24+.
  Future<void> resumeVideoRecording() async {
    _throwIfNotInitialized('resumeVideoRecording');
    if (!value.isRecordingVideo) {
      throw CameraException(
        'No video is recording',
        'resumeVideoRecording was called when no video is recording.',
      );
    }
    try {
      await CameraPlatform.instance.resumeVideoRecording(_cameraId);
      value = value.copyWith(isRecordingPaused: false);
    } on PlatformException catch (e) {
      throw CameraException(e.code, e.message);
    }
  }

  /// Returns a widget showing a live camera preview.
  Widget buildPreview() {
    _throwIfNotInitialized('buildPreview');
    try {
      return CameraPlatform.instance.buildPreview(_cameraId);
    } on PlatformException catch (e) {
      throw CameraException(e.code, e.message);
    }
  }

  /// Gets the maximum supported zoom level for the selected camera.
  Future<double> getMaxZoomLevel() {
    _throwIfNotInitialized('getMaxZoomLevel');
    try {
      return CameraPlatform.instance.getMaxZoomLevel(_cameraId);
    } on PlatformException catch (e) {
      throw CameraException(e.code, e.message);
    }
  }

  /// Gets the minimum supported zoom level for the selected camera.
  Future<double> getMinZoomLevel() {
    _throwIfNotInitialized('getMinZoomLevel');
    try {
      return CameraPlatform.instance.getMinZoomLevel(_cameraId);
    } on PlatformException catch (e) {
      throw CameraException(e.code, e.message);
    }
  }

  /// Set the zoom level for the selected camera.
  ///
  /// The supplied [zoom] value should be between 1.0 and the maximum supported
  /// zoom level returned by the `getMaxZoomLevel`. Throws an `CameraException`
  /// when an illegal zoom level is suplied.
  Future<void> setZoomLevel(double zoom) {
    _throwIfNotInitialized('setZoomLevel');
    try {
      return CameraPlatform.instance.setZoomLevel(_cameraId, zoom);
    } on PlatformException catch (e) {
      throw CameraException(e.code, e.message);
    }
  }

  /// Sets the flash mode for taking pictures.
  Future<void> setFlashMode(FlashMode mode) async {
    try {
      await CameraPlatform.instance.setFlashMode(_cameraId, mode);
      value = value.copyWith(flashMode: mode);
    } on PlatformException catch (e) {
      throw CameraException(e.code, e.message);
    }
  }

  /// Sets the exposure mode for taking pictures.
  Future<void> setExposureMode(ExposureMode mode) async {
    try {
      await CameraPlatform.instance.setExposureMode(_cameraId, mode);
      value = value.copyWith(exposureMode: mode);
    } on PlatformException catch (e) {
      throw CameraException(e.code, e.message);
    }
  }

  /// Sets the exposure point for automatically determining the exposure value.
  ///
  /// Supplying a `null` value will reset the exposure point to it's default
  /// value.
  Future<void> setExposurePoint(Offset? point) async {
    if (point != null && (point.dx < 0 || point.dx > 1 || point.dy < 0 || point.dy > 1)) {
      throw ArgumentError('The values of point should be anywhere between (0,0) and (1,1).');
    }

    try {
      await CameraPlatform.instance.setExposurePoint(
        _cameraId,
        point == null
            ? null
            : Point<double>(
                point.dx,
                point.dy,
              ),
      );
    } on PlatformException catch (e) {
      throw CameraException(e.code, e.message);
    }
  }

  /// Gets the minimum supported exposure offset for the selected camera in EV units.
  Future<double> getMinExposureOffset() async {
    _throwIfNotInitialized('getMinExposureOffset');
    try {
      return CameraPlatform.instance.getMinExposureOffset(_cameraId);
    } on PlatformException catch (e) {
      throw CameraException(e.code, e.message);
    }
  }

  /// Gets the maximum supported exposure offset for the selected camera in EV units.
  Future<double> getMaxExposureOffset() async {
    _throwIfNotInitialized('getMaxExposureOffset');
    try {
      return CameraPlatform.instance.getMaxExposureOffset(_cameraId);
    } on PlatformException catch (e) {
      throw CameraException(e.code, e.message);
    }
  }

  /// Gets the supported step size for exposure offset for the selected camera in EV units.
  ///
  /// Returns 0 when the camera supports using a free value without stepping.
  Future<double> getExposureOffsetStepSize() async {
    _throwIfNotInitialized('getExposureOffsetStepSize');
    try {
      return CameraPlatform.instance.getExposureOffsetStepSize(_cameraId);
    } on PlatformException catch (e) {
      throw CameraException(e.code, e.message);
    }
  }

  /// Sets the exposure offset for the selected camera.
  ///
  /// The supplied [offset] value should be in EV units. 1 EV unit represents a
  /// doubling in brightness. It should be between the minimum and maximum offsets
  /// obtained through `getMinExposureOffset` and `getMaxExposureOffset` respectively.
  /// Throws a `CameraException` when an illegal offset is supplied.
  ///
  /// When the supplied [offset] value does not align with the step size obtained
  /// through `getExposureStepSize`, it will automatically be rounded to the nearest step.
  ///
  /// Returns the (rounded) offset value that was set.
  Future<double> setExposureOffset(double offset) async {
    _throwIfNotInitialized('setExposureOffset');
    // Check if offset is in range
    final List<double> range = await Future.wait(<Future<double>>[getMinExposureOffset(), getMaxExposureOffset()]);
    if (offset < range[0] || offset > range[1]) {
      throw CameraException(
        'exposureOffsetOutOfBounds',
        'The provided exposure offset was outside the supported range for this device.',
      );
    }

    // Round to the closest step if needed
    final double stepSize = await getExposureOffsetStepSize();
    if (stepSize > 0) {
      final double inv = 1.0 / stepSize;
      double roundedOffset = (offset * inv).roundToDouble() / inv;
      if (roundedOffset > range[1]) {
        roundedOffset = (offset * inv).floorToDouble() / inv;
      } else if (roundedOffset < range[0]) {
        roundedOffset = (offset * inv).ceilToDouble() / inv;
      }
      offset = roundedOffset;
    }

    try {
      return CameraPlatform.instance.setExposureOffset(_cameraId, offset);
    } on PlatformException catch (e) {
      throw CameraException(e.code, e.message);
    }
  }

  /// Locks the capture orientation.
  ///
  /// If [orientation] is omitted, the current device orientation is used.
  Future<void> lockCaptureOrientation([DeviceOrientation? orientation]) async {
    try {
      await CameraPlatform.instance.lockCaptureOrientation(_cameraId, orientation ?? value.deviceOrientation);
      value = value.copyWith(lockedCaptureOrientation: orientation ?? value.deviceOrientation);
    } on PlatformException catch (e) {
      throw CameraException(e.code, e.message);
    }
  }

  /// Sets the focus mode for taking pictures.
  Future<void> setFocusMode(FocusMode mode) async {
    try {
      await CameraPlatform.instance.setFocusMode(_cameraId, mode);
      value = value.copyWith(focusMode: mode);
    } on PlatformException catch (e) {
      throw CameraException(e.code, e.message);
    }
  }

  /// Unlocks the capture orientation.
  Future<void> unlockCaptureOrientation() async {
    try {
      await CameraPlatform.instance.unlockCaptureOrientation(_cameraId);
      value = value.copyWith();
    } on PlatformException catch (e) {
      throw CameraException(e.code, e.message);
    }
  }

  /// Sets the focus point for automatically determining the focus value.
  ///
  /// Supplying a `null` value will reset the focus point to it's default
  /// value.
  Future<void> setFocusPoint(Offset? point) async {
    if (point != null && (point.dx < 0 || point.dx > 1 || point.dy < 0 || point.dy > 1)) {
      throw ArgumentError('The values of point should be anywhere between (0,0) and (1,1).');
    }
    try {
      await CameraPlatform.instance.setFocusPoint(
        _cameraId,
        point == null
            ? null
            : Point<double>(
                point.dx,
                point.dy,
              ),
      );
    } on PlatformException catch (e) {
      throw CameraException(e.code, e.message);
    }
  }

  /// Releases the resources of this camera.
  @override
  Future<void> dispose() async {
    if (_isDisposed) {
      return;
    }
    _unawaited(_deviceOrientationSubscription?.cancel());
    _isDisposed = true;
    super.dispose();
    if (_initCalled != null) {
      await _initCalled;
      await CameraPlatform.instance.dispose(_cameraId);
    }
  }

  void _throwIfNotInitialized(String functionName) {
    if (!value.isInitialized) {
      throw CameraException(
        'Uninitialized CameraController',
        '$functionName() was called on an uninitialized CameraController.',
      );
    }
    if (_isDisposed) {
      throw CameraException(
        'Disposed CameraController',
        '$functionName() was called on a disposed CameraController.',
      );
    }
  }

  @override
  void removeListener(VoidCallback listener) {
    // Prevent ValueListenableBuilder in CameraPreview widget from causing an
    // exception to be thrown by attempting to remove its own listener after
    // the controller has already been disposed.
    if (!_isDisposed) {
      super.removeListener(listener);
    }
  }
}