import 'dart:io';

import 'package:cartoonizer/Common/importFile.dart';

import 'print_option_screen.dart';

class Print {
  static Future<void> open(
    BuildContext context, {
    required String source,
    required File file,
  }) async {
    Events.printIconClick(source: source);
    return Navigator.of(context).push<void>(MaterialPageRoute(
      settings: RouteSettings(name: "/PrintOptionScreen"),
      builder: (context) => PrintOptionScreen(
        file: file,
        source: source,
      ),
    ));
  }
}
