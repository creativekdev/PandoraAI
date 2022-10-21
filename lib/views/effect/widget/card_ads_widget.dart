import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/admob/banner_ads_holder.dart';
import 'package:cartoonizer/Widgets/admob/card_ads_holder.dart';
import 'package:cartoonizer/config.dart';

class CardAdsWidget extends StatefulWidget {
  double width;
  double height;

  CardAdsWidget({
    Key? key,
    required this.width,
    required this.height,
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
        adId: AdMobConfig.BANNER_AD_ID,
        onUpdated: () {
          if(mounted) {
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
      return Container();
    }
  }
}
