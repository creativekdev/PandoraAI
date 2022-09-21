import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Controller/recent_controller.dart';
import 'package:cartoonizer/Widgets/admob/card_ads_holder.dart';
import 'package:cartoonizer/models/EffectModel.dart';

// todo 随机逻辑还未编写，数据结构暂无
class EffectRandomFragment extends StatefulWidget {
  late List<EffectModel> dataList;
  RecentController recentController;
  String tabString;
  int tabId;

  EffectRandomFragment({
    Key? key,
    required this.tabId,
    required this.recentController,
    required this.dataList,
    required this.tabString,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return EffectRandomFragmentState();
  }
}

class EffectRandomFragmentState extends State<EffectRandomFragment> {
  List<EffectModel> effectModelList = [];
  late RecentController recentController;
  ScrollController scrollController = ScrollController();
  double marginTop = $(110);
  late CardAdsMap adsMap;
  late double cardWidth;
  final double adScale = 1.55;

  @override
  initState() {
    super.initState();
    marginTop = $(110) + ScreenUtil.getStatusBarHeight();
    effectModelList = widget.dataList;
    recentController = widget.recentController;
    cardWidth = (ScreenUtil.screenSize.width - $(38)) / 2;
    adsMap = CardAdsMap(
        width: cardWidth,
        onUpdated: () {
          setState(() {});
        },
        scale: adScale);
    delay(() {
      // buildDataList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
