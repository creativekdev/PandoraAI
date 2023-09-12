import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/widgets/gallery/pick_album.dart';
import 'package:cartoonizer/widgets/gallery/pick_album_navigation_bar.dart';
import 'package:photo_manager/photo_manager.dart';

class AlbumPopup extends StatefulWidget {
  AssetPathEntity selectedAlbum;
  List<AssetPathEntity> albums;

  AlbumPopup({
    Key? key,
    required this.albums,
    required this.selectedAlbum,
  }) : super(key: key);

  @override
  State<AlbumPopup> createState() => _AlbumPopupState();
}

class _AlbumPopupState extends State<AlbumPopup> {
  late List<AssetPathEntity> albums;
  late AssetPathEntity selectedAlbum;

  @override
  void initState() {
    super.initState();
    albums = widget.albums;
    selectedAlbum = widget.selectedAlbum;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0x77000000),
        body: Column(
          children: [
            PickAlbumNavigationBar(
              backIcon: Icon(
                Icons.close,
                size: $(22),
                color: ColorConstant.White,
              ).hero(tag: leadingTag),
              middle: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    selectedAlbum.name,
                    style: TextStyle(
                      color: ColorConstant.White,
                      fontSize: $(17),
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                    ),
                  ).intoMaterial(color: Colors.transparent),
                  SizedBox(width: 6),
                  Icon(
                    Icons.keyboard_arrow_up_rounded,
                    size: $(18),
                    color: Color(0xff404040),
                  ).intoContainer(decoration: BoxDecoration(color: ColorConstant.White, borderRadius: BorderRadius.circular(32))),
                ],
              ).intoContainer(
                padding: EdgeInsets.only(top: 3, bottom: 3, left: 12, right: 10),
                decoration: BoxDecoration(
                  color: Color(0xff404040),
                  borderRadius: BorderRadius.circular($(64)),
                ),
              ),
            ),
            SingleChildScrollView(
              physics: ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: albums.transfer((e, index) => buildItem(context, e, index)
                        .intoContainer(
                      color: Colors.transparent,
                      width: ScreenUtil.screenSize.width,
                    )
                        .intoGestureDetector(onTap: () {
                      Navigator.of(context).pop(e);
                    })),
              ).intoMaterial(color: ColorConstant.BackgroundColor, elevation: 4, borderRadius: BorderRadius.circular(4)),
            ).intoContainer(
              constraints: BoxConstraints(maxHeight: ScreenUtil.screenSize.height / 1.5),
            ),
          ],
        )).intoGestureDetector(onTap: () {
      Navigator.of(context).pop();
    });
  }

  Future<Uint8List?> getFirstMedium(AssetPathEntity album) async {
    var list = await album.getAssetListRange(start: 0, end: 1);
    if (list.isEmpty) {
      return null;
    }
    return await list.first.thumbnailDataWithSize(ThumbnailSize($(55).toInt(), $(55).toInt()));
  }

  Widget buildItem(BuildContext context, AssetPathEntity e, int index) {
    return Row(
      children: [
        FutureBuilder<Uint8List?>(
            future: getFirstMedium(e),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.data == null) {
                  return Container();
                }
                return Image.memory(
                  snapshot.data!,
                  fit: BoxFit.cover,
                );
              } else {
                return CircularProgressIndicator().intoContainer(width: $(25), height: $(25)).intoCenter();
              }
            }).intoContainer(width: $(55), height: $(55)),
        SizedBox(width: 16),
        Expanded(
            child: Row(
          children: [
            Text(
              e.name,
              style: TextStyle(
                color: ColorConstant.White,
                fontSize: $(15),
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
                overflow: TextOverflow.ellipsis,
              ),
              maxLines: 1,
            ),
            FutureBuilder<int>(
                future: e.assetCountAsync,
                builder: (context, snapShot) {
                  if (snapShot.connectionState == ConnectionState.done) {
                    return Text(
                      '  ${snapShot.data}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: $(15),
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                        overflow: TextOverflow.ellipsis,
                      ),
                      maxLines: 1,
                    );
                  }
                  return Container();
                }),
          ],
        )),
        Image.asset(
          Images.ic_album_checked,
          width: $(16),
        ).visibility(visible: e.id == selectedAlbum.id),
        SizedBox(width: 12),
      ],
    ).intoContainer(
        decoration: BoxDecoration(
            color: Color(0xff292929),
            border: Border(
              top: index == 0 ? BorderSide.none : BorderSide(width: 1, color: Color(0xff444444)),
            )));
  }
}
