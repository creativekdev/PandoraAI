import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/blank_area_intercept.dart';
import 'package:photo_gallery/photo_gallery.dart';

class AlbumPopup extends StatefulWidget {
  List<Album> albums;

  AlbumPopup({Key? key, required this.albums}) : super(key: key);

  @override
  State<AlbumPopup> createState() => _AlbumPopupState();
}

class _AlbumPopupState extends State<AlbumPopup> {
  late List<Album> albums;

  @override
  void initState() {
    super.initState();
    albums = widget.albums;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              Scrollbar(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 5,
                        width: 1,
                      ),
                      ...albums
                          .map((e) => Text(
                                '${e.name} (${e.count})' ?? '',
                                style: TextStyle(
                                  color: ColorConstant.White,
                                  fontSize: $(17),
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Poppins',
                                ),
                                maxLines: 2,
                              ).intoContainer(width: ScreenUtil.screenSize.width * 0.55, padding: EdgeInsets.symmetric(vertical: $(12), horizontal: $(15))).intoGestureDetector(
                                  onTap: () {
                                Navigator.of(context).pop(e);
                              }))
                          .toList()
                    ],
                  ).intoMaterial(color: ColorConstant.BackgroundColor, elevation: 4, borderRadius: BorderRadius.circular(4)),
                ),
                thumbVisibility: true,
              ).intoContainer(
                constraints: BoxConstraints(maxHeight: ScreenUtil.screenSize.height - ScreenUtil.getStatusBarHeight() - $(80)),
              )
            ],
          ).intoContainer(color: Colors.transparent, alignment: Alignment.center).intoGestureDetector(onTap: () {
            Navigator.of(context).pop();
          }),
        ));
  }
}
