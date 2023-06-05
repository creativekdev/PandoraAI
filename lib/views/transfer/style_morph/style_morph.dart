import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/gallery/pick_album.dart';
import 'package:cartoonizer/common/Extension.dart';
import 'package:cartoonizer/views/transfer/style_morph/style_morph_screen.dart';

class StyleMorph {
  static Future open(BuildContext context, String source) async {
    var list = await PickAlbumScreen.pickImage(context, count: 1);
    if (list == null || list.isEmpty) {
      return;
    }
    var first = await list.first.file;
    if (first == null || !first.existsSync()) {
      //todo
      CommonExtension().showToast('Image not exist');
      return;
    }
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StyleMorphScreen(source: source, path: first.path),
        settings: RouteSettings(name: 'StyleMorphScreen'),
      ),
    );
  }
}
