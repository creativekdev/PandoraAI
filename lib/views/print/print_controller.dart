import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/api/cartoonizer_api.dart';

import '../../models/print_option_entity.dart';
import '../../models/print_product_entity.dart';
import '../../models/print_product_info_entity.dart';
import '../../network/dio_node.dart';

class PrintController extends GetxController {
  PrintController({required this.optionData});

  PrintOptionData optionData;
  late CartoonizerApi cartoonizerApi;

  PrintProductEntity? product;
  PrintProductInfoEntity? productInfo;

  Map<String, dynamic> options = {};
  List<Map<String, bool>> showesed = [];
  Map<String, String> selectOptions = {};

  bool _viewInit = false;

  set viewInit(bool value) {
    _viewInit = value;
    update();
  }

  bool get viewInit => _viewInit;

  onSuccess(PrintProductEntity entity, PrintProductInfoEntity info) {
    _viewInit = true;
    product = entity;
    productInfo = info;
    options = getOptionsData(entity);
    showesed = getInitIsShowed(options.keys.toList());
    update();
  }

  onTapOptions(Map<String, bool> map) {
    for (var i = 0; i < showesed.length; i++) {
      final temp = showesed[i];
      if (temp.keys.first == map.keys.first) {
        temp[map.keys.first] = !temp[map.keys.first]!;
        showesed[i] = temp;
      } else {
        temp[map.keys.first] = false;
      }
    }
    update();
  }

  onTapOption(Map<String, bool> map, String value) {
    selectOptions[map.keys.first] = value;
    update();
  }

  @override
  void onInit() {
    super.onInit();
    cartoonizerApi = CartoonizerApi().bindController(this);
    onRequestData();
  }

  onRequestData() async {
    final shopify = cartoonizerApi.shopifyProducts(
        product_ids: optionData.shopifyProductId, is_admin_shop: 1);
    print("127.0.0.1 v === 1111 ${optionData.contentUrl}");
    final productInfo = DioNode().build().get(optionData.contentUrl);

    dynamic response = await productInfo;
    print("127.0.0.1 === 1111 ${response.runtimeType}");
    print("127.0.0.1 === 1111 ${response.data}");
    // print("127.0.0.1 === 1111 ${data.body}");


    PrintProductInfoEntity? productInfoEntity =
    PrintProductInfoEntity.fromJson(response.data);
    print("127.0.0.1 === 1111 $productInfoEntity");
    PrintProductEntity? shopifyProduct = await shopify;

    //    // PrintProductInfoEntity? productInfoEntity =
    //     await productInfo as PrintProductInfoEntity?;
    // if (shopifyProduct != null && productInfoEntity != null)
    //   onSuccess(shopifyProduct, productInfoEntity!);
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void dispose() {
    super.dispose();
    cartoonizerApi.unbind();
  }

  List<Map<String, bool>> getInitIsShowed(List<String> keys) {
    List<Map<String, bool>> isShowed = [];
    for (var i = 0; i < keys.length; i++) {
      isShowed.add({keys[i]: false});
    }
    return isShowed;
  }

  Map<String, dynamic> getOptionsData(PrintProductEntity entity) {
    Map<String, dynamic> map = {};
    for (var i = 0; i < entity.data.rows.first.variants.edges.length; i++) {
      PrintProductDataRowsVariantsEdges edges =
      entity.data.rows.first.variants.edges[i];
      for (var j = 0; j < edges.node.selectedOptions.length; j++) {
        PrintProductDataRowsVariantsEdgesNodeSelectedOptions option =
        edges.node.selectedOptions[j];
        if (map.keys.contains(option.name)) {
          List<String> list = map[option.name]!;
          if (!list.contains(option.value)) {
            map[option.name]!.add(option.value);
          }
        } else {
          map[option.name] = [option.value];
        }
      }
    }
    return map;
  }
}
