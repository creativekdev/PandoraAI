import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/search_bar.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/generated/json/base/json_convert_content.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/models/region_code_entity.dart';
import 'package:cartoonizer/views/common/region/calling_codes_zh.dart';
import 'package:common_utils/common_utils.dart';

import 'calling_codes_en.dart';
import 'calling_codes_es.dart';

class SelectRegionPage extends StatefulWidget {
  static Future<RegionCodeEntity?> pickRegion(BuildContext context) async {
    return Navigator.of(context).push(MaterialPageRoute(
      settings: RouteSettings(name: "/SelectRegionPage"),
      builder: (context) => SelectRegionPage(),
    ));
  }

  const SelectRegionPage({Key? key}) : super(key: key);

  @override
  State<SelectRegionPage> createState() => _SelectRegionPageState();
}

class _SelectRegionPageState extends State<SelectRegionPage> {
  List<RegionCodeEntity> dataList = [];
  late TextEditingController keywordController;

  @override
  void initState() {
    super.initState();
    print(AppContext.currentLocales);
    keywordController = TextEditingController();
    delay(() {
      setState(() {
        dataList = jsonConvert.convertListNotNull<RegionCodeEntity>(_getCallingCodeList())!;
      });
    });
  }

  needShown(RegionCodeEntity data) {
    var keyword = keywordController.text;
    if (TextUtil.isEmpty(keyword)) {
      return true;
    }
    if (data.regionName!.toUpperCase().contains(keyword.toUpperCase())) {
      return true;
    }
    if (data.callingCode!.contains(keyword)) {
      return true;
    }
    if (data.regionCode!.toUpperCase().contains(keyword.toUpperCase())) {
      return true;
    }
    if (data.regionSyllables.isNotEmpty) {
      var join = data.regionSyllables.join('');
      if (join.contains(keyword.toLowerCase())) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.BackgroundColor,
      appBar: AppNavigationBar(
        backgroundColor: ColorConstant.BackgroundColor,
        middle: Text(
          S.of(context).SELECT_COUNTRY_CALLING_CODE,
          style: TextStyle(fontFamily: 'Poppins', fontSize: $(18), color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          SearchBar(
            controller: keywordController,
            onChange: (content) {
              setState(() {});
            },
            onSearchClear: () {
              setState(() {});
            },
            searchIcon: Image.asset(
              Images.ic_search,
              width: $(20),
              // color: Colors.white,
            ),
            clearIcon: Icon(
              Icons.close,
              size: $(20),
              color: Color(0xff999999),
            ).intoContainer(padding: EdgeInsets.symmetric(horizontal: $(12))),
            hint: S.of(context).SELECT_COUNTRY_KEYWORD,
          ).intoContainer(
              padding: EdgeInsets.only(left: $(12)),
              margin: EdgeInsets.symmetric(horizontal: $(15)),
              decoration: BoxDecoration(
                color: Color(0xff1b1c1d),
                borderRadius: BorderRadius.circular($(32)),
              )),
          Expanded(
              child: ListView.builder(
            itemBuilder: (context, index) {
              var country = dataList[index];
              return Offstage(
                offstage: !needShown(country),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          '${country.regionFlag}',
                          style: TextStyle(
                            color: Color(0xfff9f9f9),
                            fontSize: $(18),
                            fontFamily: 'Poppins',
                          ),
                        ),
                        Expanded(
                            child: Text(
                          ' ${country.regionName}',
                          style: TextStyle(
                            color: Color(0xfff9f9f9),
                            fontSize: $(14),
                            fontFamily: 'Poppins',
                          ),
                        )),
                        Text(
                          country.callingCode!,
                          style: TextStyle(color: Color(0xfff9f9f9), fontFamily: 'Poppins', fontSize: $(14), fontWeight: FontWeight.w300),
                        ),
                      ],
                    ).intoContainer(padding: EdgeInsets.only(left: $(15), top: $(6), right: $(15), bottom: $(6))),
                    Divider(
                      height: 1,
                      color: Color(0xff323232),
                    ).intoContainer(margin: EdgeInsets.symmetric(horizontal: $(15))),
                  ],
                ).intoInkWell(onTap: () {
                  Navigator.pop(context, country);
                }).intoMaterial(color: Colors.transparent),
              );
            },
            itemCount: dataList.length,
          )),
        ],
      ),
    ).blankAreaIntercept();
  }

  List<Map<String, dynamic>> _getCallingCodeList() {
    if (AppContext.currentLocales == 'en') {
      return calling_code_en;
    } else if (AppContext.currentLocales == 'zh') {
      return calling_code_zh;
    } else if (AppContext.currentLocales == 'es') {
      return calling_code_es;
    }
    return calling_code_en;
  }

}
