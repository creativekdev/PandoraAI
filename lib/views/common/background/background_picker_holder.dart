import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/utils/string_ex.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'background_picker.dart';
import 'widgets/back_image_picker.dart';
import 'widgets/back_template_picker.dart';

class BackgroundPickerHolder extends StatefulWidget {
  double imageRatio;

  BackgroundPickerHolder({
    super.key,
    required this.imageRatio,
  });

  @override
  State<BackgroundPickerHolder> createState() => _BackgroundPickerHolderState();
}

class _BackgroundPickerHolderState extends AppState<BackgroundPickerHolder> with TickerProviderStateMixin {
  late AnimationController _controller;
  double imageRatio = 0;

  CacheManager cacheManager = AppDelegate().getManager();
  late double contentHeight;
  late double tipsWidth;

  dynamic resultData;

  List<dynamic> titleList = [];
  late TabController tabController;
  late PageController pageController;

  int get currentIndex => cacheManager.getInt(CacheManager.backgroundTabIndexHistory);

  set currentIndex(int index) {
    cacheManager.setInt(CacheManager.backgroundTabIndexHistory, index);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    imageRatio = widget.imageRatio;
    titleList = [
      {
        'title': 'template',
        'build': (context) => BackTemplatePicker(
            imageRatio: imageRatio,
            parent: this,
            onPickFile: (path) {
              dismiss(data: BackgroundData()..filePath = path);
            }),
      },
      {
        'title': 'album',
        'build': (context) => BackImagePicker(
            parent: this,
            onPickFile: (path) {
              dismiss(data: BackgroundData()..filePath = path);
            }),
      },
      {
        'title': 'colors',
        'build': (context) => Container(),
      }
    ];
    if (currentIndex >= titleList.length) {
      currentIndex = 0;
    }
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 150));
    tipsWidth = ScreenUtil.screenSize.width / 3 + $(8);
    contentHeight = (ScreenUtil.screenSize.height - $(44)) / 1.8;
    tabController = TabController(
      initialIndex: currentIndex,
      length: titleList.length,
      vsync: this,
    );
    pageController = PageController(initialPage: currentIndex);
    _controller.addStatusListener((status) {
      switch (status) {
        case AnimationStatus.dismissed:
          Navigator.of(context).pop(resultData);
          break;
        case AnimationStatus.forward:
          break;
        case AnimationStatus.reverse:
          break;
        case AnimationStatus.completed:
          break;
      }
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    tabController.dispose();
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                    child: Container(
                  color: Colors.transparent,
                ).intoGestureDetector(onTap: () {
                  dismiss();
                })),
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, (1 - _controller.value) * contentHeight),
                      child: child,
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: $(50),
                        height: $(5),
                        margin: EdgeInsets.symmetric(vertical: $(12)),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular($(12))),
                      ),
                      Theme(
                          data: ThemeData(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                          ),
                          child: TabBar(
                            indicatorColor: Colors.black,
                            isScrollable: true,
                            tabs: titleList
                                .map((e) => Text(
                                      e['title'].toString().intl,
                                      style: TextStyle(fontSize: $(13)),
                                    ).intoContainer(
                                        padding: EdgeInsets.symmetric(
                                      vertical: 6,
                                    )))
                                .toList(),
                            controller: tabController,
                            onTap: (index) {
                              if (currentIndex == index) {
                                return;
                              }
                              currentIndex = index;
                              pageController.jumpToPage(index);
                            },
                          )),
                      Expanded(
                        child: PageView.builder(
                          itemCount: titleList.length,
                          itemBuilder: (context, index) => (titleList[index]['build']! as WidgetBuilder)(context),
                          controller: pageController,
                          onPageChanged: (index) {
                            if (currentIndex == index) {
                              return;
                            }
                            currentIndex = index;
                            tabController.index = index;
                          },
                        ),
                      ),
                    ],
                  ).intoContainer(
                      height: contentHeight,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.only(topLeft: Radius.circular($(12)), topRight: Radius.circular($(12))),
                      )),
                ),
              ],
            )
                .intoContainer(
                  color: Color.fromRGBO(0, 0, 0, _controller.value * 0.3),
                )
                .ignore(ignoring: _controller.isAnimating);
          }),
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
    );
  }

  dismiss({dynamic data}) {
    resultData = data;
    _controller.reverse();
  }
}
