import 'package:cartoonizer/Common/ThemeConstant.dart';
import 'package:cartoonizer/Widgets/widget_extensions.dart';
import 'package:cartoonizer/utils/screen_util.dart';
import 'package:flutter/cupertino.dart';

extension DialogWidgetEx on Widget {
  Widget customDialogStyle() {
    return this
        .intoMaterial(
          color: ColorConstant.EffectFunctionGrey,
          borderRadius: BorderRadius.circular($(16)),
        )
        .intoContainer(
          padding: EdgeInsets.only(left: $(16), right: $(16), top: $(10)),
          margin: EdgeInsets.symmetric(horizontal: $(35)),
        )
        .intoCenter();
  }
}
