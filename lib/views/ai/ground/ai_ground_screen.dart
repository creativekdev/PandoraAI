import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/views/ai/ground/ai_ground_controller.dart';

class AiGroundScreen extends StatefulWidget {
  const AiGroundScreen({Key? key}) : super(key: key);

  @override
  State<AiGroundScreen> createState() => _AiGroundScreenState();
}

class _AiGroundScreenState extends AppState<AiGroundScreen> {
  AiGroundController aiGroundController = Get.put(AiGroundController());

  @override
  void dispose() {
    super.dispose();
    Get.delete<AiGroundController>();
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.BackgroundColor,
      appBar: AppNavigationBar(
        backgroundColor: ColorConstant.BackgroundColor,
        middle: TitleTextWidget(
          'Text-Image',
          ColorConstant.White,
          FontWeight.w600,
          $(17),
        ),
      ),
      body: GetBuilder<AiGroundController>(
        init: aiGroundController,
        builder: (controller) {
          return Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Enter prompt',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: $(15),
                            fontWeight: FontWeight.w600,
                            color: ColorConstant.White,
                          ),
                        ),
                        SizedBox(width: $(6)),
                        Text(
                          '${aiGroundController.editingController.text.length}/${aiGroundController.maxLength}',
                          style: TextStyle(color: Color(0xff858585)),
                        )
                      ],
                    ).intoContainer(padding: EdgeInsets.symmetric(horizontal: $(15), vertical: $(12))),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          Images.ic_text_image_tips,
                          width: $(16),
                        ),
                        SizedBox(width: $(4)),
                        Expanded(
                          child: Text(
                            'Enter a prompt to inspire the generation process. Below are some suggestions to help you get started.',
                            style: TextStyle(fontSize: $(13), color: Color(0xFF2778FF)),
                          ),
                        ),
                      ],
                    ).intoContainer(padding: EdgeInsets.symmetric(horizontal: $(15))),
                    SizedBox(height: 12),
                    TextField(
                      controller: aiGroundController.editingController,
                      decoration: InputDecoration(
                        hintText: 'Describe the image you want to see',
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: TextStyle(color: ColorConstant.White),
                      maxLines: 6,
                      maxLength: aiGroundController.maxLength,
                      buildCounter: (context, {required currentLength, required isFocused, maxLength}) {
                        return Container();
                      },
                      onChanged: (text) {
                        aiGroundController.update();
                      },
                    ).intoContainer(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade900,
                          borderRadius: BorderRadius.circular($(4)),
                        ),
                        padding: EdgeInsets.symmetric(vertical: $(6), horizontal: $(6)),
                        margin: EdgeInsets.symmetric(horizontal: $(15))),
                    controller.promptList.isEmpty
                        ? CircularProgressIndicator().intoContainer(width: $(25), height: $(25)).intoCenter().intoContainer(height: $(56))
                        : ListView.builder(
                            padding: EdgeInsets.only(left: $(15), top: $(12), bottom: $(12)),
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              return Text(
                                controller.promptList[index],
                                style: TextStyle(color: Colors.white, fontFamily: 'Poppins', fontSize: $(17), fontWeight: FontWeight.w500),
                              )
                                  .intoContainer(
                                    padding: EdgeInsets.symmetric(horizontal: $(20), vertical: $(4)),
                                    decoration: BoxDecoration(color: Color(0xFF2C2C2E), borderRadius: BorderRadius.circular(32)),
                                    margin: EdgeInsets.only(right: $(15)),
                                  )
                                  .intoGestureDetector(onTap: () {
                                    controller.onPromptClick(controller.promptList[index]);
                              });
                            },
                            itemCount: controller.promptList.length,
                          ).intoContainer(height: $(56)),
                  ],
                ),
              ),
              Positioned(
                child: Text(
                  'Play Ground',
                  style: TextStyle(color: Colors.white, fontSize: $(17), fontFamily: 'Poppins'),
                ).intoContainer(
                  width: ScreenUtil.screenSize.width - $(30),
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(vertical: $(10)),
                  decoration: BoxDecoration(
                    color: ColorConstant.DiscoveryBtn,
                    borderRadius: BorderRadius.circular($(6)),
                  ),
                  margin: EdgeInsets.symmetric(horizontal: $(15)),
                ),
                bottom: ScreenUtil.getBottomPadding(context) + $(15),
              ),
            ],
            fit: StackFit.expand,
          );
        },
      ),
    );
  }
}
