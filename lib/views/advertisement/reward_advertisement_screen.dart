import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/admob/reward_interstitial_ads_holder.dart';
import 'package:cartoonizer/Widgets/outline_widget.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/views/payment.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

class RewardAdvertisementScreen extends StatefulWidget {
  RewardInterstitialAdsHolder adsHolder;
  String watchAdText;

  static Future<bool?> push(
    BuildContext context, {
    required RewardInterstitialAdsHolder adsHolder,
    required String watchAdText,
  }) =>
      showModalBottomSheet<bool>(
          context: context,
          constraints: BoxConstraints(maxHeight: ScreenUtil.screenSize.height - ($(44) + ScreenUtil.getStatusBarHeight())),
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => RewardAdvertisementScreen(
                adsHolder: adsHolder,
                watchAdText: watchAdText,
              ));

  RewardAdvertisementScreen({
    required this.adsHolder,
    required this.watchAdText,
  });

  @override
  State<StatefulWidget> createState() {
    return RewardAdvertisementState();
  }
}

class RewardAdvertisementState extends State<RewardAdvertisementScreen> {
  Size? buyHeaderSize;
  late RewardInterstitialAdsHolder adsHolder;
  bool hasAd = false;
  bool hasReward = false;
  late StreamSubscription payListener;

  @override
  void initState() {
    super.initState();
    Posthog().screenWithUser(screenName: 'reward_advertisement_screen');
    adsHolder = widget.adsHolder;
    hasAd = adsHolder.adsReady;
    adsHolder.onRewardCall = () {
      hasReward = true;
    };
    adsHolder.onDismiss = () {
      Navigator.of(context).pop(hasReward);
    };
    payListener = EventBusHelper().eventBus.on<OnPaySuccessEvent>().listen((event) {
      hasReward = true;
    });
  }

  @override
  void dispose() {
    super.dispose();
    adsHolder.onDispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          ClipRRect(
            child: Image.asset(
              Images.ic_buy_background,
              width: double.maxFinite,
              height: double.maxFinite,
              fit: BoxFit.fitWidth,
            ),
            borderRadius: BorderRadius.only(
              topRight: Radius.circular($(24)),
              topLeft: Radius.circular($(24)),
            ),
          ),
          Icon(
            Icons.close,
            size: $(24),
            color: Colors.white,
          ).intoContainer(padding: EdgeInsets.all($(15))).intoGestureDetector(onTap: () {
            Navigator.of(context).pop(hasReward);
          }),
          Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Stack(
                fit: StackFit.loose,
                children: [
                  OutlineWidget(
                          strokeWidth: $(2),
                          radius: $(16),
                          gradient: LinearGradient(
                            colors: [Color(0xffE31ECD), Color(0xff243CFF)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          child: Column(
                            children: [
                              SizedBox(height: $(25)),
                              buildBuyAttr(context, S.of(context).buyAttrNoAds, Images.ic_bug_no_ad),
                              buildBuyAttr(context, S.of(context).buyAttrNoWatermark, Images.ic_buy_no_watermark),
                              buildBuyAttr(context, S.of(context).buyAttrHDImages, Images.ic_buy_hd_image),
                              buildBuyAttr(context, S.of(context).buyAttrFasterSpeed, Images.ic_buy_faster_convert),
                              SizedBox(height: $(20)),
                              Text(
                                S.of(context).buyNow,
                                style: TextStyle(color: Colors.white, fontSize: $(17)),
                              )
                                  .intoContainer(
                                      width: double.maxFinite,
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.symmetric(vertical: $(12)),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular($(6)),
                                        gradient: LinearGradient(
                                          colors: [Color(0xffE31ECD), Color(0xff243CFF)],
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                        ),
                                      ))
                                  .intoGestureDetector(onTap: () {
                                AppDelegate.instance.getManager<UserManager>().doOnLogin(context, logPreLoginAction: 'reward_advertisement_dialog', callback: () {
                                  PaymentUtils.pay(context, 'reward_advertisement').then((value) {
                                    Navigator.of(context).pop(hasReward);
                                  });
                                }, autoExec: true);
                              }).intoContainer(
                                margin: EdgeInsets.symmetric(horizontal: $(24)),
                              ),
                              SizedBox(height: $(24)),
                            ],
                          ).intoContainer(
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular($(16)),
                              ),
                              margin: EdgeInsets.all($(2))))
                      .intoContainer(
                    color: Colors.transparent,
                    padding: EdgeInsets.only(left: $(35), right: $(35), top: (buyHeaderSize?.height ?? 0) / 2),
                  ),
                  Align(
                    child: Container(
                      child: Text(
                        S.of(context).ppmPro,
                        style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: $(18), color: Colors.white),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: $(15), vertical: $(4)),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular($(6)),
                        gradient: LinearGradient(
                          colors: [Color(0xffE31ECD), Color(0xff243CFF)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                    ).listenSizeChanged(onSizeChanged: (size) {
                      setState(() {
                        buyHeaderSize = size;
                      });
                    }),
                    alignment: Alignment.topCenter,
                  ),
                ],
              ),
              SizedBox(height: $(20)),
              Column(
                children: [
                  Text(
                    S.of(context).watchAdHint,
                    style: TextStyle(color: Colors.white, fontSize: $(14), fontFamily: 'Poppins'),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    widget.watchAdText,
                    style: TextStyle(color: Colors.white, fontFamily: 'Poppins', fontSize: $(15), height: 1.2),
                    textAlign: TextAlign.center,
                  )
                      .intoContainer(
                          width: double.maxFinite,
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(vertical: $(8)),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular($(6)),
                            color: ColorConstant.WatchAdColor,
                          ))
                      .intoGestureDetector(onTap: () {
                    adsHolder.show();
                  }).intoContainer(
                    margin: EdgeInsets.only(left: $(24), right: $(24), top: $(12)),
                  ),
                ],
              )
                  .intoContainer(
                      width: double.maxFinite,
                      padding: EdgeInsets.symmetric(vertical: $(12)),
                      margin: EdgeInsets.only(left: $(35), right: $(35), bottom: $(20) + MediaQuery.of(context).padding.bottom),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular($(16)),
                        border: Border.all(color: ColorConstant.EffectFunctionGrey, width: $(2)),
                      ))
                  .visibility(
                    visible: hasAd,
                    maintainState: true,
                    maintainSize: true,
                    maintainAnimation: true,
                  ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildBuyAttr(BuildContext context, String title, String imageRes) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Image.asset(imageRes, width: $(24)),
        SizedBox(width: $(12)),
        Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: $(14),
            fontFamily: 'Poppins',
          ),
        ),
      ],
    ).intoContainer(margin: EdgeInsets.only(left: $(50), top: $(6)));
  }
}
