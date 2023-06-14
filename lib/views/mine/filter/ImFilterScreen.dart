
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Controller/effect_data_controller.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/outline_widget.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/views/mine/filter/GridSlider.dart';
import 'package:common_utils/common_utils.dart';


class ImFilterScreen extends StatefulWidget {
  // int tabPos;
  // int pos;
  // int itemPos;
  // EntrySource entrySource;
  // RecentEffectModel? recentEffectModel;

  ImFilterScreen({
    Key? key
  }) : super(key: key);

  @override
  _ImFilterScreenState createState() => _ImFilterScreenState();
}

class _ImFilterScreenState extends State<ImFilterScreen> with SingleTickerProviderStateMixin {
  bool isLoading = true;
  var _image = "";

  // List<ChooseTabItemInfo> tabItemList = [];
  late ItemScrollController itemScrollController;
  final ItemPositionsListener itemScrollPositionsListener = ItemPositionsListener.create();
  late double itemWidth;
  var currentItemIndex = 0.obs;
  List<String> _rightTabList = [Images.ic_effects, Images.ic_filters, Images.ic_adjusts,Images.ic_crop, Images.ic_background, Images.ic_letter];
  int selectedRightTab = 0;

  int selectedEffectID = 0;
  int selectedFilterID = 0;

  int currentAdjustID = 0;

  int selectedCropID = 0;
  @override
  void initState() {
    super.initState();
    isLoading = false;
    itemScrollController = ItemScrollController();
    itemWidth = (ScreenUtil.screenSize.width - $(90)) / 5;
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _buildRightTab() {
    List<Widget> buttons = [];
    int num  = 0;
    for(var img in _rightTabList) {
      int cur = num;
      buttons.add(GestureDetector(
        onTap: () {
          // Handle button press
          setState(() {
            selectedRightTab = cur;
          });
        },
        child: Container(
          width: 50,
          height: 50,
          decoration: (selectedRightTab == cur)?
          BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [const Color(0xFF68F0AF),const Color(0xFF05E0D5)],
            ),
            borderRadius: BorderRadius.circular(25),
            // image: DecorationImage(
            //   image: AssetImage(img),
            //   fit: BoxFit.cover,
            // ),
          ):
          BoxDecoration(
            borderRadius: BorderRadius.circular(25),
          ),
          child: FractionallySizedBox(
            widthFactor: 0.5,
            heightFactor: 0.5,
            child: DecoratedBox(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(img),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
      ));
      num++;
    }
    List<Widget> adjustbutton = [];
    adjustbutton.add(GestureDetector(
      onTap: () {
        // Handle button press
      },
      child: Container(
        width: 50,
        height: 50,
        decoration:
        BoxDecoration(
          borderRadius: BorderRadius.circular(25),
        ),
        child: FractionallySizedBox(
          widthFactor: 0.5,
          heightFactor: 0.5,
          child: DecoratedBox(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(Images.ic_reduction),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    ));
    return Align(
      alignment: Alignment.centerRight,
      child: Wrap(
        direction: Axis.vertical,
          spacing: 40,
        children: [
          Container(
            decoration: BoxDecoration(
                color: Color.fromARGB(100, 22, 44, 33),
                borderRadius: BorderRadius.all(Radius.circular(50))
            ),
            padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
            margin: const EdgeInsets.only(right: 10.0),
            height: 320,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: buttons
            )
          ),
          Container(
            decoration: BoxDecoration(
                color: Color.fromARGB(100, 22, 44, 33),
                borderRadius: BorderRadius.all(Radius.circular(50))
            ),
            padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
            margin: const EdgeInsets.only(right: 10.0),
            height: 60,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: adjustbutton
            )
          )
        ])

    );

  }

  Widget _buildInOutControlPad() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(Images.ic_camera, height: $(24), width: $(24))
            .intoGestureDetector(
          // onTap: () => showPickPhotoDialog(context),
          onTap: (){

          },
        ).intoContainer(margin: EdgeInsets.symmetric(horizontal: $(15))),
        SizedBox(width: 50),
        Image.asset(Images.ic_download, height: $(24), width: $(24))
            .intoGestureDetector(
          onTap: (){

          },
        ).intoContainer(margin: EdgeInsets.symmetric(horizontal: $(15))),
        SizedBox(width: 50),
        Image.asset(Images.ic_share_discovery, height: $(24), width: $(24))
            .intoGestureDetector(
          onTap: () {
          },
        ).intoContainer(margin: EdgeInsets.symmetric(horizontal: $(15)))
      ],
    )
        .intoContainer(
      margin: EdgeInsets.only(top: $(10), left: $(23), right: $(23), bottom: $(10)),
    );
  }
  Widget _buildImageView() {
    return Expanded(child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [Image.asset(Images.ic_choose_photo_initial_header)],
    ),);
  }
  Widget _buildEffectController(){
    return ScrollablePositionedList.separated(
      initialScrollIndex: 0,
      itemCount: 10,
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        return GestureDetector(
            onTap: () {
              setState(() {
                selectedEffectID = index;
              });
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 65,
                  height: 65,
                  decoration: (selectedEffectID == index)?
                  BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Color(0xFF05E0D5),
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                  )
                  : null
                  ,
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      margin: EdgeInsets.all(2.0),
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(Images.ic_choose_photo_initial_header),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                Text('Text',style: TextStyle(
                  color: Colors.white,
                ),),
                SizedBox(height: 2),
            ],
          )
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return Container();
      },
    ).intoContainer(
      height: itemWidth + $(40),
    );
  }
  Widget _buildFiltersController(){
    return ScrollablePositionedList.separated(
      initialScrollIndex: 0,
      itemCount: 10,
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        return GestureDetector(
            onTap: () {
              setState(() {
                selectedFilterID = index;
              });
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 65,
                  height: 65,
                  decoration: (selectedFilterID == index)?
                  BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Color(0xFF05E0D5),
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                  )
                      : null
                  ,
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      margin: EdgeInsets.all(2.0),
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(Images.ic_choose_photo_initial_header),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                Text('Text',style: TextStyle(
                  color: Colors.white,
                ),),
                SizedBox(height: 2),
              ],
            )
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return Container();
      },
    ).intoContainer(
      height: itemWidth + $(40),
    );
  }
  Widget _buildAdjust() {
    double _currentSliderValue = 0;
    List<Widget> buttons = [];
    for (int i = 0; i < 3; i++){
      int cur_i  = i;
      buttons.add(GestureDetector(
        onTap: () {
          setState(() {
            currentAdjustID = cur_i;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: (currentAdjustID == cur_i)?
            Border.all(color: const Color(0xFF05E0D5), width: 2)
            :Border.all(color: Colors.white, width: 2),
          ),
          child: CircleAvatar(
            backgroundImage: AssetImage(Images.ic_adjusts),
            radius: 25.0,
            backgroundColor: Colors.transparent,
          ),
        ),
      ));
      buttons.add(SizedBox(width: 20));
    }

    return Container(
        height: itemWidth + $(40),
        child:Column(
          children:[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: buttons,
            ),
            GridSlider(minVal: 0, maxVal: 100, currentPos: 50)
          ]
        )
    );
  }
  Widget _buildCrops() {
    List<Widget> buttons = [];
    List<List<int>> ratios = [[2, 3, 20, 30], [3,2,30,20], [3,4,22,30],[4,3,30,22],[1,1,30,30]];
    int i = 0;
    for(List<int> ratio in ratios){
      int curi = i;
      buttons.add(
          GestureDetector(
            onTap: () {
              selectedRightTab = curi;
            },
            child: Column(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  child: Center(
                    child: Container(
                      width: ratio.elementAt(2).toDouble(),
                      height: ratio.elementAt(3).toDouble(),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(width: 2.0, color: Colors.white),
                          left: BorderSide(width: 2.0, color: Colors.white),
                          right: BorderSide(width: 2.0, color: Colors.white),
                          bottom: BorderSide(width: 2.0, color: Colors.white),
                        ),
                      ),
                    ),
                  )
                ),
                SizedBox(height: 10,),
                Text(
                  ratio.elementAt(0).toString() + ":" + ratio.elementAt(1).toString(),
                  style: TextStyle(
                      color: Colors.white
                  ),
                )
              ],
            ),
          )
      );
      buttons.add(SizedBox(width: 30,));
      i++;
    }
    return Container(
      height: itemWidth + $(40),
      child:Center(
        child:Row(
          mainAxisSize: MainAxisSize.min,
          children: buttons,
        )
      )
    );
  }
  Widget _buildBackground() {
    return ScrollablePositionedList.separated(
      initialScrollIndex: 0,
      itemCount: 10,
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        return GestureDetector(
            onTap: () {
              setState(() {
                selectedFilterID = index;
              });
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 65,
                  height: 65,
                  decoration: (selectedFilterID == index)?
                  BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Color(0xFF05E0D5),
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                  )
                      : null
                  ,
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      margin: EdgeInsets.all(2.0),
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(Images.ic_choose_photo_initial_header),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 40),
              ],
            )
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return Container();
      },
    ).intoContainer(
      height: itemWidth + $(40),
    );

  }
  Widget _buildBottomTabbar() {
    switch(selectedRightTab) {
      case 0:
        return _buildEffectController();
      case 1:
        return _buildFiltersController();
      case 2:
        return _buildAdjust();
      case 3:
        return _buildCrops();
      case 4:
        return _buildBackground();
      default:
        return Container(height: itemWidth + $(10));
    }
  }
  @override
  Widget build(BuildContext context) {
    var content = LoadingOverlay(
          isLoading: isLoading,
          child: Stack(
              children: <Widget>[
                Scaffold(
                  backgroundColor: ColorConstant.BackgroundColor,
                  appBar: AppNavigationBar(
                    backAction: () async {
                      // if (await _willPopCallback(context)) {
                      Navigator.of(context).pop();
                      // }
                    },
                    backgroundColor: ColorConstant.BackgroundColor,
                    trailing: Image.asset(
                      Images.ic_share,
                      width: $(24),
                    ).intoGestureDetector(onTap: () async {
                      // shareOut();
                    }),
                  ),
                  body: Column(
                    children: [
                      _buildImageView(),
                      _buildInOutControlPad(),
                      SizedBox(height: $(8)),
                      _buildBottomTabbar(),
                      SizedBox(height: MediaQuery.of(context).padding.bottom)
                    ],
                  ),
                ).ignore(ignoring: isLoading),
                _buildRightTab()
              ]));
    if (TextUtil.isEmpty(_image)) {
      return content;
    } else {
      // return WillPopScope(
      //   onWillPop: () async {
      //     // return _willPopCallback(context);
      //   },
      //   child: content,
      // );
      return Container();
    }
  }

}
