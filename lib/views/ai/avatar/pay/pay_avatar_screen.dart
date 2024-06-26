import 'dart:io';

import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/widgets/app_navigation_bar.dart';
import 'package:cartoonizer/widgets/state/app_state.dart';
import 'package:cartoonizer/api/app_api.dart';
import 'package:cartoonizer/models/pay_plan_entity.dart';
import 'package:cartoonizer/views/ai/avatar/pay/pay_avatar_plans_screen.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

import 'pay_avatar_android.dart';
import 'pay_avatar_ios.dart';

class PayAvatarPage {
  static Future<bool?> push(
    BuildContext context,
  ) =>
      Navigator.of(context).push<bool>(MaterialPageRoute(
        settings: RouteSettings(name: '/_PayAvatarPage'),
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
  late AppApi api;
  List<PayPlanEntity> dataList = [];
  PayPlanEntity? selected;

  PayAvatarPageState() : super(canCancelOnLoading: false);

  @override
  void initState() {
    super.initState();
    Posthog().screenWithUser(screenName: 'avatar_plan_pay_screen');
    Events.avatarPlanShow();
    api = AppApi().bindState(this);
    delay(() {
      showLoading().whenComplete(() {
        api.listAllBuyPlan('ai_avatar_credit').then((value) {
          hideLoading().whenComplete(() {
            setState(() {
              this.dataList = value ?? [];
              if (dataList.isNotEmpty) {
                dataList.first.popular = true;
                selected = dataList.first;
              }
            });
          });
        });
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
          TitleTextWidget(S.of(context).checkout, ColorConstant.White, FontWeight.w600, $(26)),
          SizedBox(height: $(24)),
          TitleTextWidget(S.of(context).why_its_paid, ColorConstant.White, FontWeight.w600, $(17)),
          SizedBox(height: $(12)),
          TitleTextWidget(
            S.of(context).pandora_pay_description,
            ColorConstant.White,
            FontWeight.w600,
            $(13),
            maxLines: 10,
          ).intoContainer(padding: EdgeInsets.symmetric(horizontal: $(25))),
          SizedBox(height: $(50)),
          Expanded(
              child: ListView.builder(
            padding: EdgeInsets.only(top: $(15), bottom: $(15)),
            itemBuilder: (context, index) {
              return buildListItem(context, index, dataList[index]);
            },
            itemCount: dataList.length,
          )),
          TitleTextWidget(
            'See plans',
            ColorConstant.BlueColor,
            FontWeight.normal,
            $(13),
          ).intoContainer(padding: EdgeInsets.symmetric(horizontal: $(15), vertical: $(10))).intoGestureDetector(onTap: () {
            Navigator.push<PayPlanEntity>(
                context,
                MaterialPageRoute(
                  builder: (context) => PayAvatarPlansScreen(dataList: dataList),
                  settings: RouteSettings(name: '/PayAvatarPlansScreen'),
                )).then((value) {
              if (value != null) {
                setState(() {
                  selected = value;
                });
              }
            });
          }).visibility(visible: false),
          TitleTextWidget(
            '${S.of(context).pandora_purchase}\$${selected?.price}',
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
              showLoading().whenComplete(() {
                PayAvatarAndroid(planId: selected!.id.toString()).startPay(context, (result) {
                  hideLoading().whenComplete(() {
                    if (result) {
                      Events.avatarPlanPurchase(plan: selected!.id.toString());
                      Navigator.of(context).pop(true);
                    }
                  });
                });
              });
            } else {
              PayAvatarIOS? avatarIOS;
              showLoading().whenComplete(() {
                avatarIOS = PayAvatarIOS(
                  planId: selected!.appleStorePlanId,
                );
                avatarIOS!.startPay(context, (result) {
                  hideLoading().whenComplete(() {
                    avatarIOS?.dispose();
                    if (result) {
                      Events.avatarPlanPurchase(plan: selected!.appleStorePlanId);
                      Navigator.of(context).pop(true);
                    }
                  });
                });
              });
            }
          }).visibility(visible: selected != null),
        ],
      ).intoContainer(padding: EdgeInsets.only(bottom: ScreenUtil.getBottomPadding())),
    );
  }

  Widget buildListItem(BuildContext context, int index, PayPlanEntity entity) {
    bool checked = selected?.id == entity.id;
    Widget item = Row(
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
    ).intoContainer(padding: EdgeInsets.symmetric(vertical: $(25))).intoMaterial(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular($(8)),
        );
    Widget result;
    if (index == 0) {
      result = Stack(
        children: [
          item.marginOnly(top: 10),
          Positioned(
            child: Text(
              S.of(context).most_popular,
              style: TextStyle(color: Colors.black, fontSize: $(9), fontFamily: 'Poppins'),
            ).intoContainer(
              decoration: BoxDecoration(color: Color(0xffFED700), borderRadius: BorderRadius.circular(4)),
              padding: EdgeInsets.symmetric(horizontal: $(15), vertical: $(3)),
            ),
            right: $(40),
          )
        ],
      );
    } else {
      result = item;
    }

    return result.intoGestureDetector(onTap: () {
      setState(() {
        selected = entity;
      });
    }).intoContainer(margin: EdgeInsets.symmetric(vertical: $(10), horizontal: $(15)));
  }
}
