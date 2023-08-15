import 'dart:ui' as ui;

import 'package:cartoonizer/Common/importFile.dart';
import 'package:image/image.dart' as imgLib;

class LibImageWidgetController extends ChangeNotifier {
  imgLib.Image? _shownImage;

  imgLib.Image? get shownImage => _shownImage;

  set shownImage(imgLib.Image? value) {
    _shownImage = value;
    setupShowUIImage(shownImage!);
    notifyListeners();
  }

  ui.Image? _shownUIImage;

  ui.Image? get shownUIImage => _shownUIImage;

  set shownUIImage(ui.Image? value) {
    _shownUIImage = value;
    notifyListeners();
  }

  Future<void> setupShowUIImage(imgLib.Image libImage) async {
    ui.Image image = await toImage(libImage);
    _shownUIImage = image;
    notifyListeners();
  }

  Future<ui.Image> toImage(imgLib.Image image) async {
    final c = Completer<ui.Image>();
    // var start = DateTime.now().millisecondsSinceEpoch;
    ui.decodeImageFromPixels(
      image.data.buffer.asUint8List(),
      image.width,
      image.height,
      ui.PixelFormat.rgba8888,
      (ui.Image image) {
        c.complete(image);
      },
    );
    return c.future;
  }
}
