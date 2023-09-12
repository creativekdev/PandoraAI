import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/models/recent_entity.dart';

import 'txt2img_screen.dart';

class Txt2img {
  static Future<void> open(
    BuildContext context, {
    required String source,
    Txt2imgInitData? initData,
    RecentGroundEntity? history,
  }) async {
    Navigator.of(context).push(MaterialPageRoute(
      settings: RouteSettings(name: "/Txt2imgScreen"),
      builder: (context) => Txt2imgScreen(
        source: source,
        initData: initData,
        history: history,
      ),
    ));
  }
}
