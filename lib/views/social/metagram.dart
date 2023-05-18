import 'package:cartoonizer/common/importFile.dart';

import 'metagram_screen.dart';

class Metagram {
  static Future<void> open(
    BuildContext context, {
    required String source,
  }) async {
    Navigator.of(context).push(MaterialPageRoute(
      settings: RouteSettings(name: "/MetagramScreen"),
      builder: (context) => MetagramScreen(
        source: source,
      ),
    ));
  }
}
