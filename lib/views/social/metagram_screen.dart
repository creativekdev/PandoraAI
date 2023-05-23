import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/auth/connector_platform.dart';
import 'package:cartoonizer/Widgets/connector/platform_connector_page.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/config.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/views/share/ShareUrlScreen.dart';
import 'package:cartoonizer/views/social/widget/metagram_card.dart';
import 'package:cartoonizer/views/social/metagram_item_list_screen.dart';
import 'package:cartoonizer/views/social/widget/rotating_image.dart';

import 'metagram_controller.dart';

class MetagramScreen extends StatefulWidget {
  String source;

  MetagramScreen({Key? key, required this.source}) : super(key: key);

  @override
  State<MetagramScreen> createState() => _MetagramScreenState();
}

class _MetagramScreenState extends State<MetagramScreen> {
  MetagramController controller = Get.put(MetagramController());

  @override
  void initState() {
    super.initState();
    loadData();
  }

  loadData() {
    if (controller.hasIgConnection) {
      controller.loadMetagramData().then((value) {
        if (value) {
          controller.startLoadPage();
          // do nothing;
        } else {
          Navigator.of(context).pop();
        }
      });
    } else {
      PlatformConnectorPage.push(context, platform: ConnectorPlatform.instagram).then((value) {
        if (value ?? false) {
          loadData();
        } else {
          Navigator.of(context).pop();
        }
      });
    }
  }

  @override
  void dispose() {
    Get.delete<MetagramController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.BackgroundColor,
      body: GetBuilder<MetagramController>(
          builder: (controller) {
            return Stack(
              children: [
                MetagramCard(
                  entity: controller.data,
                  metaProcessing: controller.metaProcessing,
                  onItemClick: (entity, index) {
                    controller.scrollPosition = index;
                    Navigator.of(context).push(MaterialPageRoute(
                      settings: RouteSettings(name: "/MetagramItemListScreen"),
                      builder: (context) => MetagramItemListScreen(),
                    ));
                  },
                ).intoContainer(margin: EdgeInsets.only(top: 44 + ScreenUtil.getStatusBarHeight())),
                Container(
                  height: 44 + ScreenUtil.getStatusBarHeight(),
                  child: AppNavigationBar(
                    backgroundColor: ColorConstant.BackgroundColor,
                    middle: TitleTextWidget(controller.data?.socialPostPage?.name ?? 'Influencer', Colors.white, FontWeight.w500, $(18)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        (controller.metaProcessing
                                ? RotatingImage(
                                    child: Image.asset(
                                      Images.ic_metagram_refresh,
                                      color: Colors.white,
                                      width: $(24),
                                    ),
                                  )
                                : Image.asset(
                                    Images.ic_metagram_refresh,
                                    color: Colors.white,
                                    width: $(24),
                                  ))
                            .intoContainer(padding: EdgeInsets.all($(10)), color: Colors.transparent)
                            .intoGestureDetector(onTap: () {
                          if (controller.metaProcessing) {
                            return;
                          }
                          controller.startLoadPage(force: true);
                        }).offstage(offstage: controller.data == null),
                        Image.asset(
                          Images.ic_metagram_share_home,
                          width: $(24),
                        ).intoContainer(padding: EdgeInsets.only(left: $(10), top: $(10), bottom: $(10)), color: Colors.transparent).intoGestureDetector(onTap: () {
                          ShareUrlScreen.startShare(
                            context,
                            url: '${Config.instance.host}/metagram/${controller.slug}',
                          ).then((value) {
                            if (value != null) {
                              Events.avatarResultDetailMediaShareSuccess(platform: value);
                            }
                          });
                        }).offstage(offstage: controller.data == null),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
          init: Get.find<MetagramController>()),
    );
  }
}
