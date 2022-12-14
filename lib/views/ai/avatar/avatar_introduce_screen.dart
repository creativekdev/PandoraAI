import 'dart:math';

import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/cacheImage/cached_network_image_utils.dart';
import 'package:cartoonizer/Widgets/tabbar/app_tab_bar.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/views/ai/avatar/avatar_ai_create.dart';

import 'avatar.dart';

class AvatarIntroduceScreen extends StatefulWidget {
  bool fromTab = false;

  AvatarIntroduceScreen({
    Key? key,
    this.fromTab = false,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => AvatarIntroduceScreenState();
}

const _imgUrl = 'https://pics0.baidu.com/feed/3b292df5e0fe99250125a2e7a61f12d48cb1719b.jpeg';
const _imgUrl2 = 'https://img0.baidu.com/it/u=1578062395,3811784681&fm=253&fmt=auto&app=120&f=JPEG';

String get imgUrl => Random.secure().nextInt(20) % 2 == 0 ? _imgUrl : _imgUrl2;

class AvatarIntroduceScreenState extends State<AvatarIntroduceScreen> {
  List<String> dataList = [];
  Size? size;

  @override
  void initState() {
    super.initState();
    logEvent(Events.avatar_introduce_loading);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.BackgroundColor,
      appBar: widget.fromTab ? null : AppNavigationBar(backgroundColor: ColorConstant.BackgroundColor),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: widget.fromTab ? $(30) : $(10)),
            shaderMask(
                context: context,
                child: Text(
                  'What to Expect',
                  style: TextStyle(
                    color: ColorConstant.White,
                    fontSize: $(26),
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                )),
            SizedBox(height: $(15)),
            TitleTextWidget(
                    'The type of AI Pandora Avatars use can generate random results'
                    'and may include artistic nudes, defects or otherwise shocking'
                    'images. This is out of our countrol. Please acknowledge and accept'
                    'that risk before continue.',
                    ColorConstant.White,
                    FontWeight.w400,
                    $(13),
                    maxLines: 10)
                .intoContainer(
              padding: EdgeInsets.symmetric(horizontal: $(25)),
            ),
            Image.asset(
              Images.ic_avatar_ai_planet,
              height: $(60),
            ).intoContainer(
                alignment: Alignment.centerRight,
                padding: EdgeInsets.symmetric(
                  horizontal: $(15),
                ),
                margin: EdgeInsets.only(bottom: $(6))),
            TitleTextWidget(
                    'The better you follow these guidelines,'
                    ' the better chances for great result!',
                    Colors.white,
                    FontWeight.bold,
                    $(17),
                    maxLines: 3)
                .intoContainer(
              padding: EdgeInsets.symmetric(horizontal: $(35)),
            ),
            SizedBox(height: $(35)),
            shaderMask(
                context: context,
                child: Text(
                  'Good examples',
                  style: TextStyle(
                    color: ColorConstant.White,
                    fontSize: $(18),
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                )),
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.all($(12)),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: $(6),
                crossAxisSpacing: $(6),
              ),
              itemBuilder: (context, index) => buildItem(context, index),
              itemCount: 20,
            ),
          ],
        ),
      ),
      bottomNavigationBar: TitleTextWidget(StringConstant.txtContinue, ColorConstant.White, FontWeight.normal, $(17))
          .intoContainer(
            padding: EdgeInsets.symmetric(vertical: $(8)),
            decoration: BoxDecoration(color: ColorConstant.BlueColor, borderRadius: BorderRadius.circular($(8))),
            alignment: Alignment.center,
          )
          .intoContainer(width: ScreenUtil.screenSize.width, height: $(64), padding: EdgeInsets.symmetric(vertical: $(10), horizontal: $(15)))
          .intoGestureDetector(onTap: () {
        Avatar.create(context);
      }),
    ).intoContainer(padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom));
  }

  Widget buildItem(BuildContext context, int index) {
    return ClipRRect(
      child: CachedNetworkImageUtils.custom(
        context: context,
        imageUrl: imgUrl,
        width: (ScreenUtil.screenSize.width - $(36)) / 2,
        height: (ScreenUtil.screenSize.width - $(36)) / 2,
      ),
      borderRadius: BorderRadius.circular($(8)),
    );
  }
}
