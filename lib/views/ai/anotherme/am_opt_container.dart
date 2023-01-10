import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/images-res.dart';

class AMOptContainer extends StatelessWidget {
  GestureTapCallback onChoosePhotoTap;
  GestureTapCallback onShareDiscoveryTap;
  GestureTapCallback onDownloadTap;

  AMOptContainer({
    Key? key,
    required this.onChoosePhotoTap,
    required this.onDownloadTap,
    required this.onShareDiscoveryTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(Images.ic_camera, height: $(24), width: $(24))
            .intoGestureDetector(
              onTap: onChoosePhotoTap,
            )
            .intoContainer(
              margin: EdgeInsets.symmetric(horizontal: $(15)),
            ),
        Image.asset(Images.ic_download, height: $(24), width: $(24))
            .intoGestureDetector(
              onTap: onDownloadTap,
            )
            .intoContainer(
              margin: EdgeInsets.symmetric(horizontal: $(15)),
            ),
        Image.asset(Images.ic_share_discovery, height: $(24), width: $(24))
            .intoGestureDetector(
              onTap: onShareDiscoveryTap,
            )
            .intoContainer(
              margin: EdgeInsets.symmetric(horizontal: $(15)),
            ),
      ],
    );
  }
}
