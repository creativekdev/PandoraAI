import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/views/ai/avatar/avatar_ai_controller.dart';

class UploadLoadingDialog extends StatefulWidget {
  AvatarAiController controller;

  UploadLoadingDialog({Key? key, required this.controller}) : super(key: key);

  @override
  State<UploadLoadingDialog> createState() => _UploadLoadingDialogState();
}

class _UploadLoadingDialogState extends State<UploadLoadingDialog> with SingleTickerProviderStateMixin {
  late AvatarAiController controller;
  late AnimationController animController;
  late Animation tweenAnim;

  @override
  void initState() {
    super.initState();
    animController = AnimationController(vsync: this, duration: Duration(milliseconds: 3500));
    tweenAnim = Tween<double>(begin: 0, end: 6.9).animate(animController);
    controller = widget.controller;
    animController.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        animController.forward();
      } else if (status == AnimationStatus.completed) {
        animController.reset();
      }
    });
    animController.forward();
    controller.compressAndUpload().then((value) {
      if (mounted) {
        Navigator.of(context).pop(value);
      }
    });
  }

  @override
  void dispose() {
    animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
                animation: tweenAnim,
                builder: (context, child) {
                  int count = tweenAnim.value ~/ 1;
                  String dot = '';
                  for (int i = 0; i < count; i++) {
                    dot += '.';
                  }
                  return GetBuilder<AvatarAiController>(
                      init: controller,
                      builder: (controller) => TitleTextWidget(
                            '${S.of(context).uploading_photos}$dot',
                            ColorConstant.White,
                            FontWeight.w500,
                            $(18),
                            maxLines: 5,
                          ));
                }),
            SizedBox(height: 6),
            GetBuilder<AvatarAiController>(
                init: controller,
                builder: (controller) => TitleTextWidget(
                      '${controller.uploadedList.length}/${controller.imageList.length}',
                      ColorConstant.White,
                      FontWeight.normal,
                      $(16),
                      maxLines: 5,
                    )),
            SizedBox(height: 12),
            Divider(
              height: 1,
              color: ColorConstant.LineColor,
            ),
            TitleTextWidget(
              S.of(context).cancel,
              ColorConstant.BlueColor,
              FontWeight.w500,
              $(17),
            ).intoContainer(padding: EdgeInsets.symmetric(vertical: 10), width: double.maxFinite, color: Colors.transparent).intoGestureDetector(onTap: () {
              controller.stopUpload();
              Navigator.of(context).pop(false);
            }),
          ],
        )
            .intoContainer(
              padding: EdgeInsets.only(left: $(15), right: $(15), bottom: $(4), top: $(15)),
              margin: EdgeInsets.symmetric(horizontal: $(35), vertical: $(15)),
              decoration: BoxDecoration(color: ColorConstant.BackgroundColor, borderRadius: BorderRadius.circular(8)),
            )
            .intoCenter()
            .intoMaterial(color: Colors.transparent),
        onWillPop: () async => false);
  }
}
