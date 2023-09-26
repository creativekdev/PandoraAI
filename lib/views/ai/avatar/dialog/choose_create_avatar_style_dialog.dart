import 'package:cartoonizer/widgets/app_navigation_bar.dart';
import 'package:cartoonizer/widgets/cacheImage/cached_network_image_utils.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/avatar_ai_manager.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/models/avatar_config_entity.dart';

class ChooseCreateAvatarStyle {
  static Future<MapEntry<String, String>?> push(BuildContext context) async {
    return Navigator.of(context).push<MapEntry<String, String>>(
        MaterialPageRoute(builder: (context) => _ChooseCreateAvatarStyleDialog(), settings: RouteSettings(name: '/_ChooseCreateAvatarStyleDialog')));
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
          var roleImages = configEntity.getRoleImages();
          List<Widget> children = [];
          roleImages.forEach((key, value) {
            children.add(buildItem(context, key, configEntity.examples(key)));
          });
          return SingleChildScrollView(
            padding: EdgeInsets.only(bottom: ScreenUtil.getBottomPadding()),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: children,
            ),
          );
        },
        future: aiManager.getConfig(),
      ),
    );
  }

  Widget buildItem(BuildContext context, String key, List<String> urls) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: $(16)),
        _ExampleImageCard(itemSize: $(80), urls: urls),
        SizedBox(height: $(6)),
        TitleTextWidget(aiManager.config!.getName(key), Colors.white, FontWeight.w500, $(15)),
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
          onCreateTap(key);
        }),
        SizedBox(height: $(16)),
      ],
    ).intoContainer(
      decoration: BoxDecoration(
        color: Color(0xff16191e),
        borderRadius: BorderRadius.circular($(6)),
      ),
      margin: EdgeInsets.only(left: $(15), right: $(15), top: $(12)),
    );
  }
}

class _ExampleImageCard extends StatelessWidget {
  double itemSize;
  List<String> urls = [];

  _ExampleImageCard({required this.itemSize, required List<String> urls}) {
    if (urls.length > 3) {
      this.urls = urls.sublist(0, 3);
    } else {
      this.urls = urls;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: urls.map((e) => buildItem(context, e, itemSize * 0.8)).toList(),
          ),
        ),
        Align(
          child: buildItem(context, urls[1], itemSize)
              .intoContainer(padding: EdgeInsets.all(4), decoration: BoxDecoration(color: Color(0xff16191e), borderRadius: BorderRadius.circular($(80)))),
          alignment: Alignment.center,
        ),
      ],
    ).intoContainer(height: itemSize + $(10));
  }

  Widget buildItem(BuildContext context, String url, double size) {
    return ClipRRect(
      borderRadius: BorderRadius.circular($(60)),
      child: CachedNetworkImageUtils.custom(
        useOld: false,
        context: context,
        imageUrl: url,
        width: size,
        height: size,
      ),
    ).intoMaterial(elevation: 4, borderRadius: BorderRadius.circular(60));
  }
}
