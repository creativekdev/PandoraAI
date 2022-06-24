import 'dart:ui';

import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/refresh/headers.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/api/cartoonizer_api.dart';
import 'package:cartoonizer/models/discovery_list_entity.dart';
import 'package:cartoonizer/models/enums/app_tab_id.dart';
import 'package:cartoonizer/views/discovery/discovery_effect_detail_screen.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

import 'widget/discovery_list_card.dart';

class DiscoveryFragment extends StatefulWidget {
  AppTabId tabId;

  DiscoveryFragment({
    Key? key,
    required this.tabId,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => DiscoveryFragmentState();
}

class DiscoveryFragmentState extends AppState<DiscoveryFragment> with AutomaticKeepAliveClientMixin, AppTabState {
  EasyRefreshController _easyRefreshController = EasyRefreshController();
  int page = 0;
  int pageSize = 10;
  late CartoonizerApi api;
  List<DiscoveryListEntity> dataList = [];
  Size? navbarSize;

  @override
  void initState() {
    super.initState();
    api = CartoonizerApi().bindState(this);
    delay(() {
      _easyRefreshController.callRefresh();
    });
  }

  @override
  void dispose() {
    super.dispose();
    api.unbind();
    _easyRefreshController.dispose();
  }

  void onAttached() {
    super.onAttached();
  }

  void onDetached() {
    super.onDetached();
  }

  onLoadFirstPage() => api
          .listDiscovery(
        page: 0,
        pageSize: pageSize,
      )
          .then((value) {
        _easyRefreshController.finishRefresh();
        if (value != null) {
          page = 0;
          var list = value.getDataList<DiscoveryListEntity>();
          setState(() {
            dataList = list;
          });
        }
        _easyRefreshController.finishLoad(noMore: dataList.length != pageSize);
      });

  onLoadMorePage() => api
          .listDiscovery(
        page: page + 1,
        pageSize: pageSize,
      )
          .then((value) {
        if (value == null) {
          _easyRefreshController.finishLoad(noMore: false);
        } else {
          page++;
          var list = value.getDataList<DiscoveryListEntity>();
          setState(() {
            dataList.addAll(list);
          });
          _easyRefreshController.finishLoad(noMore: list.length != pageSize);
        }
      });

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: buildWidget(context),
    );
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Stack(
      children: [
        EasyRefresh(
          header: CartoonizerMaterialHeader(),
          controller: _easyRefreshController,
          enableControlFinishRefresh: true,
          enableControlFinishLoad: false,
          onRefresh: () async => onLoadFirstPage(),
          onLoad: () async => onLoadMorePage(),
          child: WaterfallFlow.builder(
            gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: $(8),
              mainAxisSpacing: $(8),
            ),
            itemBuilder: (context, index) => DiscoveryListCard(
              data: dataList[index],
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => DiscoveryEffectDetailScreen(data: dataList[index]),
                  settings: RouteSettings(name: "/DiscoveryEffectDetailScreen"),
                ),
              ),
            ).intoContainer(margin: EdgeInsets.only(top: index < 2 ? ((navbarSize?.height ?? 70) + $(10)) : 0)),
            itemCount: dataList.length,
          ),
        ).intoContainer(margin: EdgeInsets.symmetric(horizontal: $(15))),
        navbar(context),
      ],
    );
  }

  Widget navbar(BuildContext context) => ClipRect(
        child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppNavigationBar(
                    showBackItem: false,
                    blurAble: true,
                    backgroundColor: ColorConstant.BackgroundColorBlur,
                    middle: TitleTextWidget(
                      StringConstant.tabDiscovery,
                      ColorConstant.BtnTextColor,
                      FontWeight.w600,
                      $(18),
                    )).listenSizeChanged(onSizeChanged: (size) {
                  setState(() => navbarSize = size);
                }),
              ],
            )),
      );

  @override
  bool get wantKeepAlive => true;
}
