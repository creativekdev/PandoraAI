// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:camera/camera.dart';
import 'package:cartoonizer/views/ai/anotherme/libcopy/camera_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A widget showing a live camera preview.
class CustomIOSCameraPreview extends StatelessWidget {
  /// Creates a preview widget for the given camera controller.
  CustomIOSCameraPreview(this.controller, {Key? key, this.child}) : super(key: key);

  /// The controller for the camera that the preview is shown for.
  CustomCameraController? controller;

  /// A widget to overlay on top of the camera preview
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    if (controller?.disposed() ?? true) {
      return Container();
    }
    if (!Platform.isIOS) {
      return controller!.buildPreview();
    }
    return controller!.value.isInitialized
        ? ValueListenableBuilder<CameraValue>(
            valueListenable: controller!,
            builder: (BuildContext context, Object? value, Widget? child) {
              return AspectRatio(
                aspectRatio: (1 / controller!.value.aspectRatio),
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    controller!.disposed() ? Container() : _wrapInRotatedBox(child: controller!.buildPreview()),
                    child ?? Container(),
                  ],
                ),
              );
            },
            child: child,
          )
        : Container();
  }

  Widget _wrapInRotatedBox({required Widget child}) {
    return RotatedBox(
      quarterTurns: _getQuarterTurns(),
      child: child,
    );
  }

  int _getQuarterTurns() {
    final Map<DeviceOrientation, int> turns = <DeviceOrientation, int>{
      DeviceOrientation.portraitUp: 0,
      DeviceOrientation.landscapeRight: 1,
      DeviceOrientation.portraitDown: 2,
      DeviceOrientation.landscapeLeft: 3,
    };
    return turns[_getApplicableOrientation()]!;
  }

  DeviceOrientation _getApplicableOrientation() {
    if (controller == null) {
      return DeviceOrientation.portraitUp;
    }
    return controller!.value.isRecordingVideo
        ? controller!.value.recordingOrientation!
        : (controller!.value.previewPauseOrientation ?? controller!.value.lockedCaptureOrientation ?? controller!.value.deviceOrientation);
  }
}
