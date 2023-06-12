import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/cacheImage/cached_network_image_utils.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/avatar_ai_manager.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/models/avatar_config_entity.dart';

class ChooseCreateAvatarStyle {
  static Future<MapEntry<String, String>?> push(BuildContext context) async {
    return Navigator.of(context).push<MapEntry<String, String>>(MaterialPageRoute(builder: (context) => _ChooseCreateAvatarStyleDialog()));
  }
}

class _ChooseCreateAvatarStyleDialog extends StatefulWidget {
  _ChooseCreateAvatarStyleDialog({Key? key}) : super(key: key);

  @override
  State<_ChooseCreateAvatarStyleDialog> createState() => _ChooseCreateAvatarStyleDialogState();
}

class _ChooseCreateAvatarStyleDialogState extends State<_ChooseCreateAvatarStyleDialog> {
  AvatarAiManager aiManager = AppDelegate().getManager();
  CacheManager cacheManager = AppDelegate().getManager();
  List<String> selectedList = [];

  onCreateTap(String key) {
    int index = aiManager.dataList.length + 1;
    String name = 'Packet $index';
    Navigator.of(context).pop(MapEntry(name, key));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.BackgroundColor,
      appBar: AppNavigationBar(
        backgroundColor: ColorConstant.BackgroundColor,
        middle: TitleTextWidget(S.of(context).select_style, ColorConstant.White, FontWeight.w600, $(18)),
      ),
      body: FutureBuilder<AvatarConfigEntity?>(
        builder: (context, snapshot) {
          var configEntity = snapshot.data;
          if (snapshot.connectionState != ConnectionState.done || configEntity == null) {
            return Container();
          }
          var roleImages = configEntity.getRoleList();
          if (selectedList.isEmpty) {
            selectedList = roleImages.map((e) => e.keys.toList().first).toList();
          }
          return SingleChildScrollView(
            padding: EdgeInsets.only(bottom: ScreenUtil.getBottomPadding(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: roleImages.transfer((e, index) => buildItem(context, e, index)).toList(),
            ),
          );
        },
        future: aiManager.getConfig(),
      ),
    );
  }

  Widget buildItem(BuildContext context, Map<String, String> data, int pos) {
    var keys = data.keys.toList();
    if (keys.length != 2) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: $(16)),
          ClipRRect(
            borderRadius: BorderRadius.circular($(60)),
            child: CachedNetworkImageUtils.custom(
              useOld: false,
              context: context,
              imageUrl: data[keys.first]!,
              width: $(90),
              height: $(90),
            ),
          ).intoMaterial(elevation: 4, borderRadius: BorderRadius.circular(60)),
          SizedBox(height: $(6)),
          TitleTextWidget(aiManager.config!.getName(keys.first), Colors.white, FontWeight.w500, $(15)),
          SizedBox(height: $(16)),
          Text(
            S.of(context).create,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Poppins',
              fontSize: $(15),
            ),
          )
              .intoContainer(
            alignment: Alignment.center,
            width: double.maxFinite,
            padding: EdgeInsets.symmetric(vertical: $(8)),
            margin: EdgeInsets.symmetric(horizontal: $(15)),
            decoration: BoxDecoration(
              color: ColorConstant.DiscoveryBtn,
              borderRadius: BorderRadius.circular($(8)),
            ),
          )
              .intoGestureDetector(onTap: () {
            onCreateTap(selectedList[pos]);
          }),
          SizedBox(height: $(16)),
        ],
      ).intoContainer(
        decoration: BoxDecoration(
          color: ColorConstant.DiscoveryCommentBackground,
          borderRadius: BorderRadius.circular($(6)),
        ),
        margin: EdgeInsets.only(left: $(15), right: $(15), top: $(12)),
      );
    } else {
      String leftKey = keys.first;
      String leftValue = data[leftKey]!;
      String rightKey = keys.last;
      String rightValue = data[rightKey]!;
      return Column(
        children: [
          SizedBox(height: $(16)),
          _SelectStyleCard(
            leftKey: leftKey,
            leftValue: leftValue,
            rightKey: rightKey,
            rightValue: rightValue,
            onChange: (String key) {
              selectedList[pos] = key;
            },
          ).intoCenter(),
          SizedBox(height: $(16)),
          Text(
            S.of(context).create,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Poppins',
              fontSize: $(15),
            ),
          )
              .intoContainer(
            alignment: Alignment.center,
            width: double.maxFinite,
            padding: EdgeInsets.symmetric(vertical: $(8)),
            margin: EdgeInsets.symmetric(horizontal: $(15)),
            decoration: BoxDecoration(
              color: ColorConstant.DiscoveryBtn,
              borderRadius: BorderRadius.circular($(8)),
            ),
          )
              .intoGestureDetector(onTap: () {
            onCreateTap(selectedList[pos]);
          }),
          SizedBox(height: $(16)),
        ],
      ).intoContainer(
        decoration: BoxDecoration(
          color: ColorConstant.DiscoveryCommentBackground,
          borderRadius: BorderRadius.circular($(6)),
        ),
        margin: EdgeInsets.only(left: $(15), right: $(15), top: $(12)),
      );
    }
  }
}

class _SelectStyleCard extends StatefulWidget {
  String leftKey;
  String rightKey;
  String leftValue;
  String rightValue;
  Function(String key) onChange;

  _SelectStyleCard({
    Key? key,
    required this.leftKey,
    required this.rightKey,
    required this.rightValue,
    required this.leftValue,
    required this.onChange,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SelectStyleCardState();
  }
}

class _SelectStyleCardState extends State<_SelectStyleCard> {
  AvatarAiManager aiManager = AppDelegate().getManager();
  late String leftKey;
  late String rightKey;
  late String leftValue;
  late String rightValue;

  late String selectedKey;

  @override
  void initState() {
    super.initState();
    leftKey = widget.leftKey;
    leftValue = widget.leftValue;
    rightKey = widget.rightKey;
    rightValue = widget.rightValue;
    selectedKey = leftKey;
  }

  @override
  Widget build(BuildContext context) {
    bool checkLeft = selectedKey != rightKey;
    var children = [
      Align(
        alignment: Alignment.centerRight,
        child: ClipRRect(
          borderRadius: BorderRadius.circular($(60)),
          child: CachedNetworkImageUtils.custom(
            useOld: false,
            context: context,
            imageUrl: rightValue,
            width: !checkLeft ? $(90) : $(70),
            height: !checkLeft ? $(90) : $(70),
          ),
        ).intoMaterial(elevation: 4, borderRadius: BorderRadius.circular(60)),
      ),
      Align(
        alignment: Alignment.centerLeft,
        child: ClipRRect(
          borderRadius: BorderRadius.circular($(60)),
          child: CachedNetworkImageUtils.custom(
            useOld: false,
            context: context,
            imageUrl: leftValue,
            width: checkLeft ? $(90) : $(70),
            height: checkLeft ? $(90) : $(70),
          ),
        ).intoMaterial(elevation: 4, borderRadius: BorderRadius.circular(60)),
      ),
    ];
    if (!checkLeft) {
      children = children.reversed.toList();
    }
    return Column(
      children: [
        Stack(
          children: children,
        ).intoContainer(width: $(140), height: $(90)).intoGestureDetector(onTap: () {
          if (checkLeft) {
            widget.onChange.call(rightKey);
          } else {
            widget.onChange.call(leftKey);
          }
          setState(() {
            selectedKey = checkLeft ? rightKey : leftKey;
          });
        }).intoCenter(),
        SizedBox(height: $(6)),
        TitleTextWidget(aiManager.config!.getName(selectedKey), Colors.white, FontWeight.w500, $(15)),
      ],
    );
  }
}
