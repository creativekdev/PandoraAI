import 'dart:io';

import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/api/cartoonizer_api.dart';
import 'package:cartoonizer/models/pay_plan_entity.dart';
import 'package:cartoonizer/views/StripePaymentScreen.dart';

import 'pay_avatar_android.dart';
import 'pay_avatar_ios.dart';

class PayAvatarPage {
  static Future<bool?> push(
    BuildContext context,
  ) =>
      Navigator.of(context).push<bool>(MaterialPageRoute(
        builder: (context) => _PayAvatarPage(),
      ));
}

class _PayAvatarPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return PayAvatarPageState();
  }
}

class PayAvatarPageState extends AppState<_PayAvatarPage> {
  late CartoonizerApi api;
  List<PayPlanEntity> dataList = [];
  PayPlanEntity? selected;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      // delay(
      //   () async {
      //     Navigator.of(context)
      //         .push(
      //       MaterialPageRoute(builder: (context) => StripePaymentScreen(planId: '65000')),
      //     )
      //         .then((value) {
      //       Navigator.of(context).pop();
      //     });
      //   },
      // );
    } else {}
    api = CartoonizerApi().bindState(this);
    api.listAllBuyPlan('ai_avatar_credit').then((value) {
      if (value != null) {
        var pick = value.pick((t) => t.id == 65000);
        pick?.stripePlanId;
      }
      setState(() {
        this.dataList = value ?? [];
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    api.unbind();
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.BackgroundColor,
      appBar: AppNavigationBar(
        backgroundColor: ColorConstant.BackgroundColor,
      ),
      body: Column(
        children: [
          TitleTextWidget('Check out', ColorConstant.White, FontWeight.w600, $(26)),
          SizedBox(height: $(24)),
          TitleTextWidget('Why it\'s paid?', ColorConstant.White, FontWeight.w600, $(17)),
          SizedBox(height: $(12)),
          TitleTextWidget(
            'Magic Avatars consume tremendous '
            'computation power to create amazing avatars for you. '
            'It\'s expensive, but we made it as affordable as possible',
            ColorConstant.White,
            FontWeight.w600,
            $(13),
            maxLines: 10,
          ),
          SizedBox(height: $(35)),
          Expanded(
              child: ListView.builder(
            padding: EdgeInsets.only(top: $(30), bottom: $(15)),
            itemBuilder: (context, index) {
              return buildListItem(context, index, dataList[index]);
            },
            itemCount: dataList.length,
          )),
          TitleTextWidget(
            'Purchase for \$${selected?.price}',
            ColorConstant.White,
            FontWeight.w500,
            $(16),
          )
              .intoContainer(
            decoration: BoxDecoration(color: ColorConstant.BlueColor, borderRadius: BorderRadius.circular($(8))),
            alignment: Alignment.center,
            margin: EdgeInsets.symmetric(vertical: $(12), horizontal: $(15)),
            padding: EdgeInsets.symmetric(vertical: $(10)),
          )
              .intoGestureDetector(onTap: () {
            if (Platform.isAndroid) {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => StripePaymentScreen(planId: selected!.id.toString()))).then((value) {
                var paymentResult = GetStorage().read('payment_result');
                if (paymentResult != null && paymentResult as bool == true) {
                  Navigator.of(context).pop(true);
                }
              });
            } else {
              //todo
            }
          }).visibility(visible: selected != null),
          Platform.isIOS ? PayAvatarIOS() : PayAvatarAndroid(),
        ],
      ),
    );
  }

  Widget buildListItem(BuildContext context, int index, PayPlanEntity entity) {
    bool checked = selected?.id == entity.id;
    return Row(
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: $(15)),
          child: checked
              ? Container(
                  width: $(22),
                  height: $(22),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular($(16)),
                    border: Border.all(
                      width: 1,
                      color: checked ? ColorConstant.BlueColor : ColorConstant.White,
                    ),
                    color: ColorConstant.BlueColor,
                  ),
                  child: Icon(
                    Icons.check,
                    size: $(16),
                    color: Colors.white,
                  ),
                  padding: EdgeInsets.only(left: 2, right: 4, top: 2, bottom: 4),
                )
              : Container(
                  width: $(22),
                  height: $(22),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular($(16)),
                    border: Border.all(
                      width: 1,
                      color: ColorConstant.White,
                    ),
                  ),
                ),
        ),
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TitleTextWidget(entity.detail, ColorConstant.White, FontWeight.w500, $(17), maxLines: 5, align: TextAlign.left),
            TitleTextWidget(entity.planName, Colors.grey.shade500, FontWeight.normal, $(13), maxLines: 5, align: TextAlign.left),
          ],
        )),
        SizedBox(width: $(15)),
        TitleTextWidget('\$${entity.price}', ColorConstant.White, FontWeight.w500, $(17)),
        SizedBox(width: $(15)),
      ],
    )
        .intoContainer(padding: EdgeInsets.symmetric(vertical: $(25)))
        .intoMaterial(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular($(8)),
        )
        .intoGestureDetector(onTap: () {
      setState(() {
        selected = entity;
      });
    }).intoContainer(margin: EdgeInsets.symmetric(vertical: $(10), horizontal: $(15)));
  }
}
