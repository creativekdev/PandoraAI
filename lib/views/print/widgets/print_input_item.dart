import '../../../common/importFile.dart';
import '../../../images-res.dart';
import '../../../models/region_code_entity.dart';

typedef InputItemAction = Function();

class PrintInputItem extends StatelessWidget {
  PrintInputItem({Key? key, required this.title, required this.controller, this.completeCallback, this.focusNode, required this.width, this.canEdit = true, this.onTap})
      : super(key: key);
  final String title;
  TextEditingController controller;
  GestureTapCallback? completeCallback;
  FocusNode? focusNode;
  final double width;
  final bool canEdit;
  final InputItemAction? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: $(16)),
          TitleTextWidget(title, ColorConstant.White, FontWeight.normal, $(14), align: TextAlign.left),
          SizedBox(height: $(8)),
          TextField(
            focusNode: focusNode,
            style: TextStyle(
              color: ColorConstant.White,
              fontSize: $(14),
            ),
            maxLines: 1,
            readOnly: !canEdit,
            cursorColor: ColorConstant.White,
            controller: controller,
            onEditingComplete: () {
              FocusScope.of(context).unfocus();
              completeCallback?.call();
            },
            onTap: onTap,
            decoration: InputDecoration(
              fillColor: ColorConstant.EffectCardColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular($(8)),
                borderSide: BorderSide.none,
              ),
            ),
          ).intoContainer(
              decoration: BoxDecoration(
            color: Color(0xFF0F0F0F),
            borderRadius: BorderRadius.circular($(8)),
          )),
        ],
      ),
    );
  }
}

class PrintInputContactItem extends StatelessWidget {
  PrintInputContactItem({Key? key, required this.title, required this.controller, required this.onTap, required this.regionCodeEntity}) : super(key: key);
  final String title;
  final TextEditingController controller;
  final GestureTapCallback onTap;
  RegionCodeEntity? regionCodeEntity;

  @override
  Widget build(BuildContext context) {
    bool regionIsEmpty = regionCodeEntity == null;
    print(regionIsEmpty);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: $(16)),
        TitleTextWidget(
          title,
          ColorConstant.White,
          FontWeight.normal,
          $(14),
          align: TextAlign.left,
        ),
        SizedBox(height: $(8)),
        Container(
          height: $(48),
          decoration: BoxDecoration(
            color: Color(0xFF0F0F0F),
            borderRadius: BorderRadius.circular($(8)),
          ),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.only(left: $(125), bottom: $(9)),
                child: TextField(
                  style: TextStyle(
                    color: ColorConstant.White,
                    fontSize: $(14),
                  ),
                  cursorColor: ColorConstant.White,
                  controller: controller,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    fillColor: ColorConstant.EffectCardColor,
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(left: $(16)),
                alignment: Alignment.centerLeft,
                child: Text(
                  regionIsEmpty ? '🇺🇸' : regionCodeEntity!.regionFlag!,
                  style: TextStyle(
                    // color: Color(0xfff9f9f9),
                    fontSize: $(18),
                    fontFamily: 'Poppins',
                  ),
                ),
              ).intoGestureDetector(
                onTap: onTap,
              ),
              Container(
                padding: EdgeInsets.only(left: $(46)),
                alignment: Alignment.centerLeft,
                child: Image.asset(
                  Images.ic_down,
                  width: $(24),
                ),
              ).intoGestureDetector(
                onTap: onTap,
              ),
              Container(
                padding: EdgeInsets.only(left: $(76)),
                alignment: Alignment.centerLeft,
                child: Text(
                  regionCodeEntity?.callingCode ?? '+1',
                  style: TextStyle(
                    color: ColorConstant.White,
                    fontSize: $(14),
                    fontFamily: 'Poppins',
                  ),
                ),
              ).intoGestureDetector(
                onTap: onTap,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
