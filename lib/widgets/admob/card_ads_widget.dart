import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/widgets/admob/card_ads_holder.dart';
import 'package:cartoonizer/config.dart';

class CardAdsWidget extends StatefulWidget {
  double width;
  double height;
  int page;
  String type;

  CardAdsWidget({
    Key? key,
    required this.type,
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
        key: 'CardAdsWidget:${widget.type}:${widget.page}',
        width: widget.width,
        adId: widget.page % 2 == 0 ? AdMobConfig.INSPIRED_BANNER_AD1_ID : AdMobConfig.INSPIRED_BANNER_AD2_ID,
        onUpdated: () {
          delay(() {
            if (mounted) {
              setState(() {});
            }
          }, milliseconds: 100);
        },
        scale: widget.height / widget.width);
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
      return Container(height: 0);
    }
  }
}
