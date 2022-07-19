import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/admob/ads_holder.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/progress_bar.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';

class ProcessingAdvertisementScreen extends StatefulWidget {
  AdsHolder adsHolder;

  static push(BuildContext context, {required AdsHolder adsHolder}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => ProcessingAdvertisementScreen(
          adsHolder: adsHolder,
        ),
        settings: RouteSettings(name: "/ProcessingAdvertisementScreen"),
      ),
    );
  }

  ProcessingAdvertisementScreen({Key? key, required this.adsHolder}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ProcessingAdvertisementState();
  }
}

class ProcessingAdvertisementState extends AppState<ProcessingAdvertisementScreen> {
  late AdsHolder adsHolder;

  int progress = 40;

  @override
  void initState() {
    super.initState();
    adsHolder = widget.adsHolder;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.BackgroundColor,
      appBar: AppNavigationBar(
        backgroundColor: ColorConstant.BackgroundColor,
        backIcon: TitleTextWidget(
          StringConstant.cancel,
          ColorConstant.White,
          FontWeight.normal,
          $(16),
        ).intoPadding(padding: EdgeInsets.symmetric(horizontal: $(8), vertical: $(6))),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: AppProgressBar(
                  progress: progress,
                  dashSize: 8,
                  duration: Duration(milliseconds: 1000),
                  loadingColors: [Color(0xff3E60FF), Color(0xffffd718)],
                ),
              ),
              SizedBox(height: $(6)),
              Text(
                '${progress}%',
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: $(6)),
            ],
          ).intoContainer(margin: EdgeInsets.symmetric(horizontal: $(100)), alignment: Alignment.center)),
          adsHolder.buildAdWidget() ?? Container(),
        ],
      ),
    );
  }
}
