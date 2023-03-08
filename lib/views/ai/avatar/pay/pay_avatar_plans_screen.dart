import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/models/pay_plan_entity.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

class PayAvatarPlansScreen extends StatefulWidget {
  List<PayPlanEntity> dataList = [];

  PayAvatarPlansScreen({
    Key? key,
    required this.dataList,
  }) : super(key: key);

  @override
  State<PayAvatarPlansScreen> createState() => _PayAvatarPlansScreenState();
}

class _PayAvatarPlansScreenState extends State<PayAvatarPlansScreen> {
  List<PayPlanEntity> dataList = [];

  @override
  void initState() {
    super.initState();
    Posthog().screenWithUser(screenName: 'avatar_all_plans_screen');
    dataList = widget.dataList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ColorConstant.BackgroundColor,
        appBar: AppNavigationBar(
          backgroundColor: ColorConstant.BackgroundColor,
          middle: TitleTextWidget(S.of(context).all_plans, Colors.white, FontWeight.w600, $(17)),
        ),
        body: ListView.builder(
          padding: EdgeInsets.only(top: $(15), bottom: $(15)),
          itemBuilder: (context, index) {
            return buildListItem(context, index, dataList[index]);
          },
          itemCount: dataList.length,
        ));
  }

  Widget buildListItem(BuildContext context, int index, PayPlanEntity entity) {
    return Row(
      children: [
        SizedBox(width: $(15)),
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
      Navigator.of(context).pop(dataList[index]);
    }).intoContainer(margin: EdgeInsets.symmetric(vertical: $(10), horizontal: $(15)));
  }
}
