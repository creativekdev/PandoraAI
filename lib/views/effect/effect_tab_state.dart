import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Controller/effect_data_controller.dart';
import 'package:cartoonizer/models/push_extra_entity.dart';
import 'package:cartoonizer/views/transfer/cartoonizer/cartoonize.dart';
import 'package:common_utils/common_utils.dart';

mixin EffectTabState<T extends StatefulWidget> on State<T> {
  onEffectClick(PushExtraEntity pushExtraEntity) async {
    if (TextUtil.isEmpty(pushExtraEntity.tab)) return;
    if (TextUtil.isEmpty(pushExtraEntity.category)) return;
    EffectDataController controller = Get.find<EffectDataController>();
    var pos = controller.findItemPos(pushExtraEntity.tab, pushExtraEntity.category, pushExtraEntity.effect);
    Cartoonize.open(
      context,
      source: 'push_click',
      tabPos: pos.tabPos,
      itemPos: pos.itemPos,
      categoryPos: pos.categoryPos,
    );
  }
}
