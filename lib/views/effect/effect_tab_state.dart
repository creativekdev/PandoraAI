import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Controller/effect_data_controller.dart';
import 'package:cartoonizer/models/EffectModel.dart';
import 'package:cartoonizer/models/effect_map.dart';
import 'package:cartoonizer/models/push_extra_entity.dart';
import 'package:cartoonizer/views/transfer/ChoosePhotoScreen.dart';
import 'package:common_utils/common_utils.dart';

mixin EffectTabState<T extends StatefulWidget> on State<T> {
  onEffectClick(PushExtraEntity pushExtraEntity) async {
    if(TextUtil.isEmpty(pushExtraEntity.tab)) return;
    if(TextUtil.isEmpty(pushExtraEntity.category)) return;
    EffectDataController controller = Get.find();
    List<EffectModel> allEffectList = controller.data?.allEffectList()??[];
    EffectModel? model = allEffectList.pick((t) => t.key == pushExtraEntity.category);
    if(model == null) {
      return;
    }
    int tabPos = controller.tabList.findPosition((data) => data.key == pushExtraEntity.tab)!;
    var categoryPos = controller.tabTitleList.findPosition((data) => data.categoryKey == pushExtraEntity.category)!;
    int itemPos;
    if(TextUtil.isEmpty(pushExtraEntity.effect)) {
      EffectItem item = model.effects.values.toList()[model.getDefaultPos()];
      itemPos = controller.tabItemList.findPosition((data) => data.data.key == item.key)!;
    } else {
      itemPos = controller.tabItemList.findPosition((data) => data.data.key == pushExtraEntity.effect)!;
    }
    Events.facetoonLoading(source: 'push_click');
    await Navigator.push(
      context,
      MaterialPageRoute(
        settings: RouteSettings(name: "/ChoosePhotoScreen"),
        builder: (context) =>
            ChoosePhotoScreen(
              tabPos: tabPos,
              pos: categoryPos,
              itemPos: itemPos,
            ),
      ),
    );
  }
}
