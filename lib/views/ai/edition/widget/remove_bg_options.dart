import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/views/ai/edition/controller/remove_bg_holder.dart';
import 'package:cartoonizer/views/common/background/background_picker.dart';

class RemoveBgOptions extends StatelessWidget {
  RemoveBgHolder controller;
  AppState parentState;

  RemoveBgOptions({
    super.key,
    required this.parentState,
    required this.controller,
    required this.bottomPadding,
    required this.switchButtonPadding,
  });

  final double bottomPadding;
  final double switchButtonPadding;

  @override
  Widget build(BuildContext context) {
    controller.preBackgroundData = controller.config.selectData ?? controller.preBackgroundData;
    return BackgroundPickerBar(
      preBackgroundData: controller.preBackgroundData,
      imageRatio: controller.config.ratio,
      onPick: (BackgroundData data, bool isPopMerge) async {
        controller.onSavedBackground(data);
      },
      onColorChange: (BackgroundData data) async {
        controller.onSavedBackground(data);
      },
    ).intoContainer(
      width: double.maxFinite,
      padding: EdgeInsets.symmetric(horizontal: $(4)),
    );
  }
}
