import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/admob/ads_holder.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/progress_bar.dart';
import 'dart:math' as math;

const int minDuration = 10000; //at least shown time duration.

class ProcessingAdvertisementScreen extends StatefulWidget {
  WidgetAdsHolder adsHolder;

  /// result:
  ///   null -> user cancelled
  ///   false -> convert failed
  ///   true -> convert succeed
  static Future<bool?> push(BuildContext context, {required WidgetAdsHolder adsHolder}) {
    return Navigator.push<bool>(
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

class ProcessingAdvertisementState extends State<ProcessingAdvertisementScreen> with TickerProviderStateMixin {
  late WidgetAdsHolder adsHolder;
  late AnimationController animationController;
  late CurvedAnimation curvedAnimation;
  late AnimationController endController;
  int progress = 0;
  int convertProgress = 900;
  int endProgress = 100;
  late StreamSubscription onCartoonizerFinishedListener;
  bool? cartoonizerStatus;
  bool curvedAnimFinished = false;
  bool hasAd = false;
  List<Curve> curves = [
    Curves.linear,
    Curves.decelerate,
    Curves.ease,
    Curves.easeOut,
    Curves.easeIn,
    Curves.easeInQuart,
    Curves.easeInOut,
    Curves.easeInOutQuint,
    Curves.easeOutCubic,
  ];

  @override
  void initState() {
    super.initState();
    adsHolder = widget.adsHolder;
    hasAd = adsHolder.adsReady;
    animationController = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: minDuration + math.Random().nextInt(5000),
      ),
    );
    curvedAnimation = CurvedAnimation(parent: animationController, curve: curves[math.Random().nextInt(curves.length)]);
    curvedAnimation.addListener(() {
      setState(() {
        progress = (curvedAnimation.value * convertProgress).toInt();
      });
    });
    curvedAnimation.addStatusListener((status) {
      switch (status) {
        case AnimationStatus.dismissed:
          break;
        case AnimationStatus.forward:
          break;
        case AnimationStatus.reverse:
          break;
        case AnimationStatus.completed:
          curvedAnimFinished = true;
          if (cartoonizerStatus != null) {
            endController.forward();
          }
          break;
      }
    });
    endController = AnimationController(vsync: this, duration: Duration(seconds: 1));
    endController.addListener(() {
      setState(() {
        progress = convertProgress + (endController.value * endProgress).toInt();
      });
    });
    endController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Navigator.of(context).pop(true);
      }
    });
    onCartoonizerFinishedListener = EventBusHelper().eventBus.on<OnCartoonizerFinishedEvent>().listen((event) {
      cartoonizerStatus = event.data!;
      if (!cartoonizerStatus!) {
        Navigator.of(context).pop(false);
      } else {
        if (curvedAnimFinished) {
          endController.forward();
        }
      }
    });
    animationController.forward();
  }

  @override
  void dispose() {
    endController.dispose();
    curvedAnimation.dispose();
    animationController.dispose();
    onCartoonizerFinishedListener.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          backgroundColor: ColorConstant.BackgroundColor,
          appBar: AppNavigationBar(
            backgroundColor: ColorConstant.BackgroundColor,
            backAction: () {
              showExitDialog().then((value) {
                if (value ?? false) {
                  Navigator.of(context).pop();
                }
              });
            },
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
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppProgressBar(
                    progress: progress,
                    dashSize: 8,
                    duration: Duration(milliseconds: 1000),
                    loadingColors: [Color(0xff3E60FF), Color(0xffffd718)],
                    borderRadius: BorderRadius.circular(32),
                  ),
                  SizedBox(height: $(6)),
                  Text(
                    '${progress / 10}%',
                    style: TextStyle(color: ColorConstant.EffectFunctionBlue, fontFamily: 'Poppins'),
                  ),
                  SizedBox(height: $(6)),
                ],
              ).intoContainer(height: $(100), padding: EdgeInsets.symmetric(horizontal: $(100)), alignment: Alignment.center),
              hasAd ? Expanded(child: (adsHolder.buildAdWidget() ?? Container()).intoContainer(alignment: Alignment.center)) : placeHolder(context),
              Container(height: hasAd ? $(144) : 0),
            ],
          ),
        ),
        onWillPop: () async {
          return (await showExitDialog()) ?? false;
        });
  }

  Future<bool?> showExitDialog() {
    return showDialog<bool?>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            StringConstant.cartoonizeCancelTitle,
            style: TextStyle(
              fontSize: $(17),
              fontFamily: 'Poppins',
              color: ColorConstant.White,
            ),
            textAlign: TextAlign.center,
          ).intoContainer(margin: EdgeInsets.symmetric(horizontal: $(42), vertical: $(26))),
          Divider(height: 1, color: ColorConstant.LineColor),
          Row(
            children: [
              Expanded(
                  child: Text(
                'Keep cartooning',
                style: TextStyle(fontSize: $(16), fontFamily: 'Poppins', color: ColorConstant.White),
              )
                      .intoContainer(
                          padding: EdgeInsets.only(top: $(18), bottom: $(19)),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              border: Border(
                                  right: BorderSide(
                            width: 0.5,
                            color: ColorConstant.LineColor,
                          ))))
                      .intoGestureDetector(onTap: () {
                Navigator.pop(context);
              })),
              Expanded(
                  child: Text(
                'Insist on cancel',
                style: TextStyle(
                  fontSize: $(16),
                  fontFamily: 'Poppins',
                  color: Colors.red,
                ),
              )
                      .intoContainer(
                padding: EdgeInsets.only(top: $(18), bottom: $(19)),
                alignment: Alignment.center,
              )
                      .intoGestureDetector(onTap: () {
                Navigator.pop(context, true);
              })),
            ],
          ),
        ],
      )
          .intoMaterial(color: ColorConstant.EffectFunctionGrey, borderRadius: BorderRadius.circular($(24)))
          .intoContainer(margin: EdgeInsets.symmetric(horizontal: $(32)))
          .intoCenter()
          .intoContainer(),
    );
  }

  Widget placeHolder(BuildContext context) {
    return Container();
  }
}
