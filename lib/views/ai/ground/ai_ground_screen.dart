import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';

class AiGroundScreen extends StatefulWidget {
  const AiGroundScreen({Key? key}) : super(key: key);

  @override
  State<AiGroundScreen> createState() => _AiGroundScreenState();
}

class _AiGroundScreenState extends AppState<AiGroundScreen> {
  TextEditingController editingController = TextEditingController();

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.BackgroundColor,
      appBar: AppNavigationBar(
        backgroundColor: ColorConstant.BackgroundColor,
        middle: TitleTextWidget(
          'AI Text to Image',
          ColorConstant.White,
          FontWeight.w600,
          $(17),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: $(15),
          vertical: $(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TitleTextWidget(
              'Describe the image you want to see',
              ColorConstant.White,
              FontWeight.w600,
              $(15),
            ),
            SizedBox(height: 10),
            TextField(
              controller: editingController,
              decoration: InputDecoration(
                hintText: 'description',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              style: TextStyle(color: ColorConstant.White),
              maxLines: 8,
              maxLength: 1000,
              buildCounter: (context, {required currentLength, required isFocused, maxLength}) {
                return Text(
                  '$currentLength/$maxLength',
                  style: TextStyle(color: ColorConstant.White),
                );
              },
            ).intoContainer(
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular($(4)),
              ),
              padding: EdgeInsets.symmetric(vertical: $(6), horizontal: $(6)),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TitleTextWidget(
                    'Need Inspiration?',
                    ColorConstant.White,
                    FontWeight.w600,
                    $(15),
                    align: TextAlign.start,
                  ),
                ),
                Icon(
                  Icons.sync,
                  color: ColorConstant.BlueColor,
                ).intoGestureDetector(onTap: () {
                  showLoading().whenComplete(() {
                    hideLoading().whenComplete(() {});
                  });
                }),
              ],
            ),
            SizedBox(height: 10),
            TitleTextWidget(
              'Generate Image',
              ColorConstant.White,
              FontWeight.w600,
              $(15),
            )
                .intoContainer(
                  padding: EdgeInsets.symmetric(horizontal: $(15), vertical: 6),
                  decoration: BoxDecoration(color: ColorConstant.BlueColor, borderRadius: BorderRadius.circular($(32))),
                )
                .intoGestureDetector(onTap: () {}),
          ],
        ),
      ),
    );
  }
}
