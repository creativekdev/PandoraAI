import 'dart:io';

import 'package:cartoonizer/Common/Extension.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/cacheImage/cached_network_image_utils.dart';
import 'package:cartoonizer/Widgets/cacheImage/sync_download_file.dart';
import 'package:cartoonizer/Widgets/photo_view/photo_pager.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/app/cache/storage_operator.dart';
import 'package:cartoonizer/gallery_saver.dart';
import 'package:cartoonizer/models/avatar_ai_list_entity.dart';
import 'package:mmoo_forbidshot/mmoo_forbidshot.dart';

class AvatarDetailScreen extends StatefulWidget {
  AvatarAiListEntity entity;

  AvatarDetailScreen({
    Key? key,
    required this.entity,
  }) : super(key: key);

  @override
  State<AvatarDetailScreen> createState() => _AvatarDetailScreenState();
}

class _AvatarDetailScreenState extends AppState<AvatarDetailScreen> {
  late AvatarAiListEntity entity;
  late double itemSize;

  @override
  void initState() {
    super.initState();
    entity = widget.entity;
    itemSize = (ScreenUtil.screenSize.width - $(42)) / 2;
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
        middle: TitleTextWidget(entity.name, ColorConstant.White, FontWeight.w600, $(17)),
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.symmetric(horizontal: $(15), vertical: $(15)),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1,
                mainAxisSpacing: $(12),
                crossAxisSpacing: $(12),
              ),
              itemBuilder: (context, index) {
                var data = entity.outputImages[index];
                return CachedNetworkImageUtils.custom(
                  context: context,
                  imageUrl: data.url,
                  width: itemSize,
                  height: itemSize,
                )
                    .hero(tag: data.url)
                    .intoContainer(
                      width: itemSize,
                      height: itemSize,
                    )
                    .intoGestureDetector(onTap: () {
                  openImage(context, index);
                });
              },
              itemCount: entity.outputImages.length,
            ),
          ),
          Text(
            'Save all to album',
            style: TextStyle(color: Colors.white, fontSize: $(17)),
          )
              .intoContainer(
            padding: EdgeInsets.symmetric(vertical: $(12)),
            margin: EdgeInsets.symmetric(horizontal: $(15), vertical: $(15)),
            width: double.maxFinite,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular($(8)),
              color: ColorConstant.BlueColor,
            ),
          )
              .intoGestureDetector(onTap: () {
            showLoading().whenComplete(() async {
              var saveList = entity.outputImages;
              for (var item in saveList) {
                var file = await SyncDownloadFile(url: item.url, type: 'png').getImage();
                if (file != null) {
                  await GallerySaver.saveImage(file.path, albumName: saveAlbumName);
                }
              }
              hideLoading().whenComplete(() {
                CommonExtension().showImageSavedOkToast(context);
              });
            });
          }),
        ],
      ),
    );
  }

  void openImage(BuildContext context, final int index) {
    if (Platform.isAndroid) {
      FlutterForbidshot.setAndroidForbidOn();
    }
    List<String> images = entity.outputImages.map((e) => e.url ?? '').toList();
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) => GalleryPhotoViewWrapper(
          galleryItems: images,
          backgroundDecoration: const BoxDecoration(
            color: Colors.black,
          ),
          initialIndex: index >= images.length ? 0 : index,
          scrollDirection: Axis.horizontal,
        ),
      ),
    ).then((value) {
      if (Platform.isAndroid) {
        FlutterForbidshot.setAndroidForbidOff();
      }
    });
  }
}
