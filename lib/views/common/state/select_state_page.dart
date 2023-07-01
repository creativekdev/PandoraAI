import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/search_bar.dart' as search;
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/generated/json/base/json_convert_content.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/views/common/state/states_en.dart';
import 'package:cartoonizer/views/common/state/states_es.dart';
import 'package:cartoonizer/views/common/state/states_zh.dart';
import 'package:common_utils/common_utils.dart';

import '../../../models/state_entity.dart';

class SelectStatePage extends StatefulWidget {
  static Future<StateEntity?> pickRegion(BuildContext context, String country) async {
    return Navigator.of(context).push(MaterialPageRoute(
      settings: RouteSettings(name: "/SelectStatePage"),
      builder: (context) => SelectStatePage(
        country: country,
      ),
    ));
  }

  final String country;

  SelectStatePage({Key? key, required this.country}) : super(key: key);

  @override
  State<SelectStatePage> createState() => _SelectStatePageState(country: country);
}

class _SelectStatePageState extends State<SelectStatePage> {
  _SelectStatePageState({required this.country});

  List<StateEntity> dataList = [];
  late TextEditingController keywordController;
  final String country;

  @override
  void initState() {
    super.initState();
    keywordController = TextEditingController();
    delay(() {
      setState(() {
        dataList = jsonConvert.convertListNotNull<StateEntity>(_getStateList())!;
        print("127.0.0.1 ==== $dataList");
      });
    });
  }

  needShown(StateEntity data) {
    var keyword = keywordController.text;
    if (TextUtil.isEmpty(keyword)) {
      return true;
    }
    if (data.code!.toUpperCase().contains(keyword.toUpperCase())) {
      return true;
    }
    if (data.name!.toLowerCase().contains(keyword.toLowerCase())) {
      return true;
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
          S.of(context).SELECT_STATE,
          style: TextStyle(fontFamily: 'Poppins', fontSize: $(18), color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          search.SearchBar(
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
            hint: S.of(context).SELECT_STATE_KEYWORD,
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
                  child: _StateWithCodeCard(
                    data: country,
                  ).intoInkWell(onTap: () {
                    Navigator.pop(context, country);
                  }).intoMaterial(color: Colors.transparent),
                );
              },
              itemCount: dataList.length,
            ),
          ),
        ],
      ),
    ).blankAreaIntercept();
  }

  List<Map<String, dynamic>> _getStateList() {
    if (AppContext.currentLocales == 'en') {
      return states_en[country] ?? [];
    } else if (AppContext.currentLocales == 'zh') {
      return states_zh[country] ?? [];
    } else if (AppContext.currentLocales == 'es') {
      return states_es[country] ?? [];
    }
    return states_en[country] ?? [];
  }
}

class _StateWithCodeCard extends StatelessWidget {
  StateEntity data;

  _StateWithCodeCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              '${data.name}',
              style: TextStyle(
                color: Color(0xfff9f9f9),
                fontSize: $(16),
                fontFamily: 'Poppins',
              ),
            ),
            Spacer(),
            Text(
              data.code!,
              style: TextStyle(color: Color(0xfff9f9f9), fontFamily: 'Poppins', fontSize: $(18), fontWeight: FontWeight.w300),
            ),
          ],
        ).intoContainer(padding: EdgeInsets.only(left: $(15), top: $(6), right: $(15), bottom: $(6))),
        Divider(
          height: 1,
          color: Color(0xff323232),
        ).intoContainer(margin: EdgeInsets.symmetric(horizontal: $(15))),
      ],
    );
  }
}
