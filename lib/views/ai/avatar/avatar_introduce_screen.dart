import 'dart:math';

import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/cacheImage/cached_network_image_utils.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/views/ai/avatar/avatar_ai_create.dart';

import 'avatar.dart';

class AvatarIntroduceScreen extends StatefulWidget {
  AvatarIntroduceScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => AvatarIntroduceScreenState();
}

const _imgUrl = 'https://pics0.baidu.com/feed/3b292df5e0fe99250125a2e7a61f12d48cb1719b.jpeg@f_auto?token=e8d441ca552a9f0e42a2a01a8d1eb117';
const _imgUrl2 = 'https://img0.baidu.com/it/u=1578062395,3811784681&fm=253&fmt=auto&app=120&f=JPEG?w=620&h=372';

String get imgUrl => Random.secure().nextInt(20) % 2 == 0 ? _imgUrl : _imgUrl2;

class AvatarIntroduceScreenState extends State<AvatarIntroduceScreen> {
  List<String> dataList = [];
  Size? size;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.BackgroundColor,
      appBar: AppNavigationBar(
        backgroundColor: ColorConstant.BackgroundColor,
        backIcon: Image.asset(
          Images.ic_back,
          height: $(24),
          width: $(24),
        ).hero(tag: Avatar.logoBackTag),
        middle: TitleTextWidget('What to Expect', ColorConstant.White, FontWeight.w500, $(17)),
      ),
      bottomNavigationBar: TitleTextWidget(StringConstant.txtContinue, ColorConstant.White, FontWeight.normal, $(20))
          .intoContainer(
            padding: EdgeInsets.symmetric(vertical: $(8)),
            margin: EdgeInsets.symmetric(horizontal: $(20)),
            decoration: BoxDecoration(color: ColorConstant.BlueColor, borderRadius: BorderRadius.circular($(64))),
            alignment: Alignment.center,
          )
          .intoContainer(
            width: ScreenUtil.screenSize.width,
            height: $(50),
          )
          .intoGestureDetector(onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => AvatarAiCreateScreen()));
      }),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: $(30)),
            TitleTextWidget(
                    'The type of AI we utilise for Magic Avatars'
                    ' may generate artefacts, inaccuracies and'
                    ' defects in output images-it\'s out of our'
                    ' control, So please acknowledge and accept'
                    ' that risk before continue.',
                    ColorConstant.White,
                    FontWeight.w400,
                    $(13),
                    maxLines: 10)
                .intoContainer(
              padding: EdgeInsets.symmetric(horizontal: $(25)),
            ),
            SizedBox(height: $(30)),
            TitleTextWidget(
                    'The more variations you get, the'
                    ' better chances for great result!',
                    Colors.white,
                    FontWeight.bold,
                    $(14),
                    maxLines: 3)
                .intoContainer(
              padding: EdgeInsets.symmetric(horizontal: $(35)),
            ),
            SizedBox(height: $(30)),
            TitleTextWidget('Good examples', Colors.white, FontWeight.bold, $(14), maxLines: 3).intoContainer(
              padding: EdgeInsets.symmetric(horizontal: $(15)),
              alignment: Alignment.centerLeft,
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.all($(12)),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: $(12),
                crossAxisSpacing: $(12),
              ),
              itemBuilder: (context, index) => buildItem(context, index),
              itemCount: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildItem(BuildContext context, int index) {
    return CachedNetworkImageUtils.custom(
      context: context,
      imageUrl: imgUrl,
      width: (ScreenUtil.screenSize.width - $(36)) / 2,
      height: (ScreenUtil.screenSize.width - $(36)) / 2,
    );
  }
}
