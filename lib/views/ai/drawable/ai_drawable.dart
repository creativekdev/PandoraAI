import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/views/ai/drawable/widget/drawable.dart';

import 'ai_drawable_screen.dart';

class AiDrawable {
  static String localImageTag = 'ai-draw-local-image';

  static Future open(BuildContext context, {DrawableRecord? history, required String source}) async {
    Events.aidrawLoading(source: source);
    return Navigator.of(context).push(MaterialPageRoute(
      settings: RouteSettings(name: "/AiDrawableScreen"),
      builder: (_) => AiDrawableScreen(
        record: history,
        source: source,
      ),
    ));
  }
}
