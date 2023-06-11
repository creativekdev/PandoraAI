
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Controller/effect_data_controller.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/outline_widget.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/images-res.dart';
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
  List<String> _rightTabList = [Images.ic_effects, Images.ic_filters, Images.ic_adjusts,Images.ic_crop, Images.ic_background, Images.ic_background];
  int selectedRightTab = 0;
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

  _buildRightTab() {
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
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
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
      )

    );

  }

  _buildInOutControlPad() {
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
        Image.asset(Images.ic_download, height: $(24), width: $(24))
            .intoGestureDetector(
          onTap: (){

          },
        ).intoContainer(margin: EdgeInsets.symmetric(horizontal: $(15))),
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
  _buildImageView() {
    return Expanded(child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [Image.asset(Images.ic_choose_photo_initial_header)],
    ),);
  }
  _buildBottomTabbar() {
    return ScrollablePositionedList.separated(
      initialScrollIndex: 0,
      itemCount: 10,
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.all(2.0),
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(Images.ic_choose_photo_initial_header),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Text('Text',style: TextStyle(
              color: Colors.white,
            ),),
            SizedBox(height: 2),
          ],
        );
      },
      separatorBuilder: (BuildContext context, int index) {
          return Container();
      },
    ).intoContainer(
      height: itemWidth + $(10),
    );
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
