import 'package:cartoonizer/Common/importFile.dart';

import 'ai_ground_screen.dart';

class AiGround {
  static Future<void> open(BuildContext context, {required String source, AiGroundInitData? initData}) async {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => AiGroundScreen(
        source: source,
        initData: initData,
      ),
    ));
  }
}
