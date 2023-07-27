import 'package:skeletons/skeletons.dart';

import '../../Common/importFile.dart';

class HomeEffectSkeletonView extends StatelessWidget {
  const HomeEffectSkeletonView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SkeletonListView(
      scrollable: false,
      itemCount: 4,
      spacing: $(16),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Column(
            children: [
              SizedBox(height: ScreenUtil.getStatusBarHeight()),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular($(10)),
                  color: ColorConstant.ShadowColor,
                ),
                height: (ScreenUtil.screenSize.width - $(30)) * 0.75,
              ),
              SizedBox(
                height: $(16),
              )
            ],
          );
        }
        if (index == 1) {
          return Column(
            children: [
              Wrap(
                spacing: $(8),
                runSpacing: $(8),
                children: List.filled(
                  8,
                  ClipRRect(
                    borderRadius: BorderRadius.circular($(8)),
                    child: Container(
                      height: (ScreenUtil.screenSize.width - $(60)) / 4,
                      width: (ScreenUtil.screenSize.width - $(60)) / 4,
                      color: ColorConstant.ShadowColor,
                    ),
                  ),
                ),
              ),
              SizedBox(height: $(16))
            ],
          );
        }
        if (index == 2) {
          return Column(
            children: [
              Wrap(
                spacing: $(8),
                runSpacing: $(8),
                children: List.filled(
                  3,
                  Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular($(8)),
                        child: Container(
                          height: ((ScreenUtil.screenSize.width - $(50)) / 4) * 192.0 / 110.0,
                          width: (ScreenUtil.screenSize.width - $(52)) / 3,
                          color: ColorConstant.ShadowColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: $(16),
              )
            ],
          );
        }
        return Wrap(
          spacing: $(8),
          runSpacing: $(8),
          children: List.filled(
            3,
            Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular($(8)),
                  child: Container(
                    height: $(120),
                    width: (ScreenUtil.screenSize.width - $(48)) / 3,
                    color: ColorConstant.ShadowColor,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).intoContainer(margin: EdgeInsets.only(top: 55 + ScreenUtil.getBottomBarHeight()));
  }
}
