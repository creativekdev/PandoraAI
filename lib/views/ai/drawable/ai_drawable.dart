import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/models/recent_entity.dart';

import 'ai_drawable_screen.dart';

class AiDrawable {
  static String localImageTag = 'ai-draw-local-image';
  static Future open(BuildContext context,{RecentMetaverseEntity? entity, required String source}) async {
    Events.aidrawLoading(source: source);
    return Navigator.of(context).push(MaterialPageRoute(builder: (_) => AiDrawableScreen()));
  }
}
