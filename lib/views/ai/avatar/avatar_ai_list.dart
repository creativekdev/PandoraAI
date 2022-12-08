import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/cacheImage/cached_network_image_utils.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/views/ai/avatar/avatar_ai_controller.dart';
import 'package:cartoonizer/views/ai/avatar/avatar_introduce_screen.dart';
import 'package:cartoonizer/views/ai/avatar/select_gender_screen.dart';

import 'avatar.dart';

class AvatarAiCreateScreen extends StatelessWidget {
  AvatarAiController controller = Get.put(AvatarAiController());
  late double imageWidth;
  late double imageHeight;

  AvatarAiCreateScreen({Key? key}) : super(key: key) {
    imageWidth = ScreenUtil.screenSize.width / 4;
    imageHeight = imageWidth * 1.25;
  }

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
        middle: TitleTextWidget('Upload photos', ColorConstant.White, FontWeight.w500, $(17)),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
              child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 20).intoContainer(
                  padding: EdgeInsets.symmetric(horizontal: $(15)),
                ),
                buildIconText(context, title: 'Good photo examples', icon: Images.ic_checked),
                SizedBox(height: 12),
                TitleTextWidget(
                  'Close-up selfies, same person, adults, '
                  'variety of backgrounds, facial expressions, '
                  'head tilts and angles',
                  ColorConstant.White,
                  FontWeight.normal,
                  $(14),
                  maxLines: 5,
                  align: TextAlign.left,
                ).intoContainer(
                  padding: EdgeInsets.symmetric(horizontal: $(15)),
                ),
                SizedBox(height: 12),
                ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: $(15)),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) => buildListItem(context, index, true),
                  itemCount: 10,
                ).intoContainer(height: imageHeight, width: ScreenUtil.screenSize.width),
                SizedBox(height: 20),
                buildIconText(context, title: 'Bad photo examples', icon: Images.ic_checked),
                SizedBox(height: 12),
                TitleTextWidget(
                  'Group shots, full-length, kids, covered faces,'
                  ' animals, monotonous pics, nudes',
                  ColorConstant.White,
                  FontWeight.normal,
                  $(14),
                  align: TextAlign.left,
                  maxLines: 5,
                ).intoContainer(
                  padding: EdgeInsets.symmetric(horizontal: $(15)),
                ),
                SizedBox(height: 12),
                ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: $(15)),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) => buildListItem(context, index, false),
                  itemCount: 10,
                ).intoContainer(height: imageHeight, width: ScreenUtil.screenSize.width),
              ],
            ),
          )),
          TitleTextWidget(
            'Group shots, full-length, kids, covered faces,'
            ' animals, monotonous pics, nudes',
            ColorConstant.White,
            FontWeight.normal,
            $(14),
            align: TextAlign.center,
            maxLines: 5,
          ).intoContainer(padding: EdgeInsets.symmetric(horizontal: $(30))),
          Text(
            'Select 10-20 selfies',
            style: TextStyle(color: Colors.white),
          )
              .intoContainer(
            padding: EdgeInsets.symmetric(vertical: $(12)),
            margin: EdgeInsets.symmetric(horizontal: $(15), vertical: $(15)),
            width: double.maxFinite,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular($(32)),
              color: ColorConstant.BlueColor,
            ),
          )
              .intoGestureDetector(onTap: () {
            //todo
            SelectGenderScreen.push(context).then((value) {

            });
          })
        ],
      ),
    );
  }

  Widget buildListItem(BuildContext context, int index, bool checked) {
    return Stack(
      children: [
        CachedNetworkImageUtils.custom(context: context, imageUrl: imgUrl, width: 40, height: 40).intoContainer(
          width: imageWidth,
          height: imageHeight,
          margin: EdgeInsets.only(left: index == 0 ? 0 : $(12)),
        ),
        Positioned(
          child: Icon(
            checked ? Icons.check_box : Icons.disabled_by_default,
            size: $(22),
            color: checked ? ColorConstant.BlueColor : ColorConstant.Red,
          ),
          right: 4,
          bottom: 4,
        ),
      ],
    ).intoContainer(
      width: imageWidth,
      height: imageHeight,
    );
  }

  Widget buildIconText(
    BuildContext context, {
    required String title,
    required String icon,
  }) {
    return Row(
      children: [
        Image.asset(
          icon,
          width: $(18),
        ),
        Expanded(
            child: TitleTextWidget(
          title,
          ColorConstant.White,
          FontWeight.w500,
          $(17),
          align: TextAlign.left,
        ))
      ],
    ).intoContainer(
      padding: EdgeInsets.symmetric(horizontal: $(15)),
    );
  }
}
