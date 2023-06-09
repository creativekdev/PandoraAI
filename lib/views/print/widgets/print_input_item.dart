import '../../../Common/importFile.dart';
import '../../../images-res.dart';
import '../../../models/region_code_entity.dart';

class PrintInputItem extends StatelessWidget {
  PrintInputItem({Key? key, required this.title, required this.controller, this.completeCallback}) : super(key: key);
  final String title;
  TextEditingController controller;
  GestureTapCallback? completeCallback;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: $(16)),
        TitleTextWidget(title, ColorConstant.White, FontWeight.normal, $(14), align: TextAlign.left),
        SizedBox(height: $(8)),
        TextField(
          style: TextStyle(
            color: ColorConstant.White,
            fontSize: $(14),
          ),
          maxLines: 1,
          cursorColor: ColorConstant.White,
          controller: controller,
          onEditingComplete: () {
            FocusScope.of(context).unfocus();
            completeCallback?.call();
          },
          decoration: InputDecoration(
            fillColor: ColorConstant.EffectCardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular($(8)),
              borderSide: BorderSide.none,
            ),
          ),
        ).intoContainer(
            decoration: BoxDecoration(
          color: ColorConstant.EffectCardColor,
          borderRadius: BorderRadius.circular($(8)),
        )),
      ],
    );
  }
}

class PrintInputContactItem extends StatelessWidget {
  PrintInputContactItem({Key? key, required this.title, required this.controller, required this.onTap, required this.regionCodeEntity}) : super(key: key);
  final String title;
  final TextEditingController controller;
  GestureTapCallback onTap;
  RegionCodeEntity? regionCodeEntity;

  @override
  Widget build(BuildContext context) {
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
            color: ColorConstant.EffectCardColor,
            borderRadius: BorderRadius.circular($(8)),
          ),
          child: Stack(
            children: [
              Container(
                padding: EdgeInsets.only(left: $(16)),
                alignment: Alignment.centerLeft,
                child: Text(
                  regionCodeEntity?.regionFlag ?? '🇺🇸',
                  style: TextStyle(
                    color: Color(0xfff9f9f9),
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
                  regionCodeEntity?.regionCode ?? '+1',
                  style: TextStyle(
                    color: Color(0x7FFFFFFF),
                    fontSize: $(14),
                    fontFamily: 'Poppins',
                  ),
                ),
              ).intoGestureDetector(
                onTap: onTap,
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(left: $(100)),
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
              )
            ],
          ),
        ),
      ],
    );
  }
}
