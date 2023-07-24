import 'dart:io';

import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/api/app_api.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/images-res.dart';

const String _kConsumableId = 'io.socialbook.cartoonizer.monthly';
const String _kUpgradeId = 'io.socialbook.cartoonizer.yearly';

class SubscribeDetailScreen extends StatefulWidget {
  const SubscribeDetailScreen({Key? key}) : super(key: key);

  @override
  State<SubscribeDetailScreen> createState() => _SubscribeDetailScreenState();
}

class _SubscribeDetailScreenState extends AppState<SubscribeDetailScreen> {
  List<String> _kProductIds = <String>[
    _kConsumableId,
    _kUpgradeId,
  ];

  UserManager userManager = AppDelegate.instance.getManager();
  late AppApi api;

  bool _showPurchasePlan = false;
  List<PurchaseDetails> _purchases = [];
  List<ProductDetails> _products = [];
  ProductDetails? currentPlan;

  @override
  initState() {
    super.initState();
    api = AppApi().bindState(this);
    delay(() async {
      _showPurchasePlan = await getSubscriptionState();
      getCurrentPlan();
      setState(() {});
    });
  }

  @override
  dispose() {
    super.dispose();
    api.unbind();
  }

  Future<bool> getSubscriptionState() async {
    Completer<bool> obj = Completer();
    if (Platform.isIOS) {
      showLoading();
      final InAppPurchase _inAppPurchase = InAppPurchase.instance;

      ProductDetailsResponse productDetailResponse = await _inAppPurchase.queryProductDetails(_kProductIds.toSet());
      if (productDetailResponse.error == null) {
        _products = productDetailResponse.productDetails;
      } else {
        _products = [];
      }
      // reload user by get login
      await userManager.refreshUser();
      var user = userManager.user!;
      if (user.userSubscription.containsKey('id')) {
        obj.complete(true);
      } else {
        obj.complete(false);
      }
    } else if (Platform.isAndroid) {
      showLoading();
      userManager.refreshUser().then((value) {
        hideLoading();
        if (userManager.user != null) {
          if (userManager.user!.userSubscription.containsKey('id')) {
            obj.complete(true);
          } else {
            obj.complete(false);
          }
        }
      });
    } else {
      obj.complete(false);
    }
    return obj.future;
  }

  void getCurrentPlan() async {
    if (Platform.isIOS) {
      final InAppPurchase _inAppPurchase = InAppPurchase.instance;

      for (int i = 0; i < _purchases.length; i++) {
        if (_purchases[i].pendingCompletePurchase) {
          _inAppPurchase.completePurchase(_purchases[i]);
        }
      }

      var year, month;
      for (int i = 0; i < _products.length; i++) {
        if (_products[i].id == _kConsumableId) {
          month = _products[i];
        } else if (_products[i].id == _kUpgradeId) {
          year = _products[i];
        }
      }

      if (_showPurchasePlan) {
        var user = userManager.user!;
        bool isMonthlyPlan = user.userSubscription['plan_type'] == 'monthly';
        currentPlan = isMonthlyPlan ? month : year;
      }
    } else if (Platform.isAndroid) {
    } else {
      currentPlan = null;
    }
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.CardColor,
      appBar: AppNavigationBar(
        backgroundColor: ColorConstant.EffectCardColor,
        middle: TitleTextWidget(
          'My Subscription',
          ColorConstant.White,
          FontWeight.w600,
          $(18),
        ),
      ),
      body: Column(
        children: [
          _showPurchasePlan ? buildSubscriptionCard(context) : buildUnSubscription(),
        ],
      ),
    );
  }

  Widget buildSubscriptionCard(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset(Images.ic_app, width: $(48)),
        SizedBox(height: $(8)),
        TitleTextWidget('PandoraAI PRO', ColorConstant.White, FontWeight.w500, $(17)),
        SizedBox(height: $(8)),
        Platform.isIOS ? buildIOSDetails(context) : buildAndroidDetails(context),
      ],
    ).intoContainer(
      padding: EdgeInsets.symmetric(horizontal: $(16), vertical: $(16)),
      margin: EdgeInsets.symmetric(horizontal: $(16)),
      decoration: BoxDecoration(
        color: ColorConstant.EffectCardColor,
        borderRadius: BorderRadius.circular($(10)),
      ),
    );
  }

  Widget buildUnSubscription() {
    return Container();
  }

  Widget buildIOSDetails(BuildContext context) {
    var pick = _products.pick((t) => t.id == userManager.user!.userSubscription['apple_store_plan_id']);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(height: 1, color: ColorConstant.White),
        SizedBox(height: $(8)),
        TitleTextWidget('${pick!.description}: ${pick.price}', Colors.white, FontWeight.normal, $(15)),
        SizedBox(height: $(8)),
        TitleTextWidget('${pick.currencySymbol}: ${pick.price}', Colors.white, FontWeight.normal, $(15)),
      ],
    );
  }

  Widget buildAndroidDetails(BuildContext context) {
    return Column(
      children: [TitleTextWidget('text', Colors.white, FontWeight.normal, $(14))],
    );
  }
}
