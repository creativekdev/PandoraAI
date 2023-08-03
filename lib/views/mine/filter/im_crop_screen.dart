import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/views/mine/filter/im_cropper.dart';

import '../../../Common/importFile.dart';
import '../../../Widgets/app_navigation_bar.dart';
import '../../../images-res.dart';
import 'im_crop_controller.dart';

typedef OnGetCropPath = void Function(String path);

class ImCropScreen extends StatefulWidget {
  ImCropScreen({Key? key, required this.filePath, this.cropRect = Rect.zero, required this.onGetCropPath}) : super(key: key);
  final String filePath;
  final Rect cropRect;
  final OnGetCropPath onGetCropPath;

  @override
  State<ImCropScreen> createState() => _ImCropScreenState();
}

class _ImCropScreenState extends AppState<ImCropScreen> {
  final controller = Get.put(ImCropController());

  @override
  void initState() {
    super.initState();
    controller.filePath = widget.filePath;
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xaa000000),
      appBar: AppNavigationBar(
        backgroundColor: Color(0xaa000000),
        trailing: Image.asset(Images.ic_confirm, width: $(30), height: $(30)).intoGestureDetector(onTap: () async {
          String path = await controller.onSaveImage();
          widget.onGetCropPath(path);
          Navigator.of(context).pop();
        }),
      ),
      body: Column(children: [
        Expanded(
          child: Center(
            child: ImCropper(
                cropperKey: controller.cropperKey,
                crop: controller.crop,
                filePath: widget.filePath,
                updateSacle: (details, ratio) {
                  controller.onUpdateScale(details, ratio);
                },
                endSacle: (details, ratio) {
                  controller.onEndScale(details, ratio);
                }),
          ),
        ),
        _buildCrops(),
        SizedBox(height: ScreenUtil.getBottomPadding(context)),
      ]),
    );
  }

  Widget _buildCrops() {
    List<Widget> buttons = [];
    int i = 0;
    for (String title in controller.crop.titles[controller.crop.isPortrait]) {
      int curi = i;
      buttons.add(GestureDetector(
        onTap: () {
          setState(() {
            controller.crop.selectedID = curi;
            controller.crop.isPortrait = controller.crop.isPortrait;
            print("127.0.0.1 - 127.0.0.1");
          });
        },
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(color: (controller.crop.selectedID == curi) ? Color(0xFF05E0D5) : Colors.white),
            )
          ],
        ),
      ));
      buttons.add(SizedBox(
        width: $(30),
      ));
      i++;
    }
    return Container(
        height: $(115),
        child: Center(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            (controller.crop.selectedID >= 2)
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () {
                          // Handle button press
                          setState(() {
                            controller.crop.isPortrait = 0;
                          });
                        },
                        child: Container(
                          child: (controller.crop.isPortrait == 0) ? Image.asset(Images.ic_landscape_selected) : Image.asset(Images.ic_landscape), // Replace with your image path
                        ),
                      ),
                      SizedBox(width: $(30)),
                      InkWell(
                        onTap: () {
                          // Handle button press
                          setState(() {
                            controller.crop.isPortrait = 1;
                          });
                        },
                        child: Container(
                          child: (controller.crop.isPortrait == 1) ? Image.asset(Images.ic_portrat_selected) : Image.asset(Images.ic_portrat), // Replace with your image path
                        ),
                      )
                    ],
                  )
                : SizedBox(
                    height: $(32),
                  ),
            SizedBox(
              height: $(30),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: buttons,
            )
          ],
        )));
  }

  @override
  void dispose() {
    Get.delete<ImCropController>();
    super.dispose();
  }
}
