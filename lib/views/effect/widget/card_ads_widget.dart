import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/admob/banner_ads_holder.dart';
import 'package:cartoonizer/Widgets/admob/card_ads_holder.dart';
import 'package:cartoonizer/config.dart';

class CardAdsWidget extends StatefulWidget {
  double width;
  double height;
  int page;

  CardAdsWidget({
    Key? key,
    required this.width,
    required this.height,
    required this.page,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return CardAdsWidgetState();
  }
}

class CardAdsWidgetState extends State<CardAdsWidget> {
  late CardAdsHolder cardAdsHolder;

  @override
  initState() {
    super.initState();
    cardAdsHolder = CardAdsHolder(
        width: widget.width,
        adId: widget.page % 2 == 0 ? AdMobConfig.INSPIRED_BANNER_AD1_ID : AdMobConfig.INSPIRED_BANNER_AD2_ID,
        onUpdated: () {
          if (mounted) {
            setState(() {});
          }
        },
        scale: 1);
    cardAdsHolder.initHolder();
  }

  @override
  dispose() {
    super.dispose();
    cardAdsHolder.onDispose();
  }

  @override
  Widget build(BuildContext context) {
    if (cardAdsHolder.adsReady) {
      return cardAdsHolder.buildAdWidget() ?? Container();
    } else {
      return CircularProgressIndicator().intoContainer(width: $(25), height: $(25)).intoCenter();
    }
  }
}
