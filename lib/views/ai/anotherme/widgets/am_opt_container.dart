import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/images-res.dart';

class AMOptContainer extends StatelessWidget {
  GestureTapCallback onChoosePhotoTap;
  GestureTapCallback onShareTap;
  GestureTapCallback onShareDiscoveryTap;
  GestureTapCallback onDownloadTap;
  GestureTapCallback onGenerateAgainTap;

  AMOptContainer({
    Key? key,
    required this.onChoosePhotoTap,
    required this.onDownloadTap,
    required this.onShareDiscoveryTap,
    required this.onGenerateAgainTap,
    required this.onShareTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Image.asset(
          Images.ic_camera,
          width: $(24),
        )
            .intoContainer(
                alignment: Alignment.center,
                width: $(48),
                height: $(48),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  color: Color(0x88000000),
                ))
            .intoGestureDetector(onTap: onChoosePhotoTap),
        SizedBox(width: $(16)),
        Expanded(
            child: Text(
          S.of(context).generate_again,
          style: TextStyle(
            color: ColorConstant.White,
            fontSize: $(17),
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
          ),
        )
                .intoContainer(
                  height: $(48),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    color: Color(0x88000000),
                  ),
                )
                .intoGestureDetector(onTap: onGenerateAgainTap)),
        SizedBox(width: $(16)),
        Column(
          children: [
            Image.asset(
              Images.ic_share,
              width: $(24),
            )
                .intoContainer(
                    alignment: Alignment.center,
                    width: $(48),
                    height: $(48),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      color: Color(0x88000000),
                    ))
                .intoGestureDetector(onTap: onShareTap),
            SizedBox(height: $(16)),
            Image.asset(
              Images.ic_share_discovery,
              width: $(24),
            )
                .intoContainer(
                    alignment: Alignment.center,
                    width: $(48),
                    height: $(48),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      color: Color(0x88000000),
                    ))
                .intoGestureDetector(onTap: onShareDiscoveryTap),
            SizedBox(height: $(16)),
            Image.asset(
              Images.ic_download,
              width: $(24),
            )
                .intoContainer(
                    alignment: Alignment.center,
                    width: $(48),
                    height: $(48),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      color: Color(0x88000000),
                    ))
                .intoGestureDetector(onTap: onDownloadTap),
          ],
        ).intoContainer(width: $(48)),
      ],
    ).intoContainer(width: ScreenUtil.screenSize.width, padding: EdgeInsets.symmetric(horizontal: $(15)));
  }
}
