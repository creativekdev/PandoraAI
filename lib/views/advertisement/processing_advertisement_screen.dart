import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/admob/card_ads_holder.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/config.dart';

class ProcessingAdvertisementScreen extends StatefulWidget {
  static push(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => ProcessingAdvertisementScreen(),
        settings: RouteSettings(name: "/ProcessingAdvertisementScreen"),
      ),
    );
  }

  ProcessingAdvertisementScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ProcessingAdvertisementState();
  }
}

class ProcessingAdvertisementState extends AppState<ProcessingAdvertisementScreen> {
  late CardAdsHolder cardAdsHolder;

  @override
  void initState() {
    super.initState();
    cardAdsHolder = CardAdsHolder(
      width: ScreenUtil.screenSize.width,c
      onUpdated: () {
        hideLoading();
        // setState(() {});
      },
      adId: AdMobConfig.PROCESSING_AD_ID,
    );
    cardAdsHolder.onReady();
    delay(() => showLoading());
  }

  @override
  void dispose() {
    super.dispose();
    cardAdsHolder.onDispose();
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.BackgroundColor,
      appBar: AppNavigationBar(
        backgroundColor: ColorConstant.BackgroundColor,
        backIcon: Icon(
          Icons.close,
          color: Colors.white,
          size: $(24),
        ).intoPadding(padding: EdgeInsets.symmetric(horizontal: $(8), vertical: $(6))),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          cardAdsHolder.buildBannerAd() ?? Container(),
        ],
      ),
    );
  }
}
