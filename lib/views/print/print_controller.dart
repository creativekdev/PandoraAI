import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/api/cartoonizer_api.dart';
import 'package:cartoonizer/models/print_product_need_info_entity.dart';
import 'package:common_utils/common_utils.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../models/print_option_entity.dart';
import '../../models/print_product_entity.dart';
import '../../network/dio_node.dart';
import '../ai/anotherme/another_me_controller.dart';

class PrintController extends GetxController {
  PrintController({required this.optionData});

  PrintOptionData optionData;
  late CartoonizerApi cartoonizerApi;

  PrintProductEntity? product;
  PrintProductNeedInfoEntity? productInfo;
  AnotherMeController acontroller = Get.find();

  Map<String, dynamic> options = {};
  List<Map<String, bool>> showesed = [];
  Map<String, String> selectOptions = {};

  // 获取图片的真实显示尺寸
  Size _imgSize = Size.zero;

  set imgSize(Size value) {
    _imgSize = value;
    update();
  }

  Size get imgSize => _imgSize;

  // 获取缩放比例
  double _scale = 1;

  set scale(double value) {
    _scale = value;
    update();
  }

  double get scale => _scale;

  // 起点
  Offset _origin = Offset.zero;

  set origin(Offset value) {
    _origin = value;
    update();
  }

  Offset get origin => _origin;

  // size
  Size _size = Size.zero;

  set size(Size value) {
    _size = value;
    update();
  }

  Size get size => _size;

  int _quatity = 1;

  set quatity(int value) {
    _quatity = value;
    update();
  }

  int get quatity => _quatity;

  double _total = 0;

  set total(double value) {
    _total = value;
    update();
  }

  double get total => _total;

  String _imgUrl = "";

  set imgUrl(String value) {
    _imgUrl = value;
    update();
  }

  String get imgUrl => _imgUrl;

  bool _viewInit = false;

  set viewInit(bool value) {
    _viewInit = value;
    update();
  }

  bool get viewInit => _viewInit;

  onSuccess(PrintProductEntity entity, PrintProductNeedInfoEntity info) {
    _viewInit = true;
    product = entity;
    productInfo = info;
    options = getOptionsData(entity);
    showesed = getInitIsShowed(options.keys.toList());
    _scale = getImageScale(productInfo?.printInfo.width.toDouble() ?? 0.0);
    _origin = getOrigiPosition(productInfo?.printInfo.pages.first.x as double, productInfo?.printInfo.pages.first.y as double);
    _size = getImageRealSize(productInfo?.printInfo.pages.first.width as double, productInfo?.printInfo.pages.first.height as double);
    _imgSize = getImageRealSize(productInfo?.printInfo.width.toDouble() ?? 0.0, productInfo?.printInfo.height.toDouble() ?? 0.0);
    LogUtil.d("scale === $_scale");
    LogUtil.d("size === $_size");
    _total = getSubTotal();
    update();
  }

  onTapOptions(Map<String, bool> map, int index) {
    for (var i = 0; i < showesed.length; i++) {
      final temp = showesed[i];
      if (i == index) {
        temp[temp.keys.first] = !temp[temp.keys.first]!;
      } else {
        temp[temp.keys.first] = false;
      }
      showesed[i] = temp;
    }
    update();
  }

  onTapOption(Map<String, bool> map, String value) {
    selectOptions[map.keys.first] = value;
    _imgUrl = getImgUrl();
    update();
  }

  onAddTap() {
    _quatity++;
    _total = getSubTotal();
    update();
  }

  onSubTap() {
    if (_quatity > 1) {
      _quatity--;
      _total = getSubTotal();
    } else {
      Fluttertoast.showToast(msg: "qiuatity can't less than 1");
    }
    update();
  }

  getSubTotal() {
    double total = _quatity * double.parse(product?.data.rows.first.variants.edges.first.node.price ?? "0");
    return getNeedDouble(total);
  }

  double getNeedDouble(double num) {
    String numString = num.toStringAsFixed(2);
    return double.parse(numString);
  }

  String getImgUrl() {
    if (selectOptions["Color"] != null) {
      return productInfo?.printInfo.productColorMap[selectOptions["Color"]];
    }
    return optionData.thumbnail ?? "";
  }

  @override
  void onInit() {
    super.onInit();
    cartoonizerApi = CartoonizerApi().bindController(this);
    _imgUrl = getImgUrl();
    onRequestData();
  }

  bool onSubmit() {
    // TODO: 检查是否选择了各种条件

    return true;
  }

  onRequestData() async {
    final shopify = cartoonizerApi.shopifyProducts(product_ids: optionData.shopifyProductId, is_admin_shop: 1);

    final productInfo = DioNode().build().get(optionData.contentUrl);
    dynamic response = await productInfo;
    if (response.statusCode != 200) {
      Get.back();
    }
    PrintProductNeedInfoEntity? productInfoEntity = PrintProductNeedInfoEntity.fromJson(response.data);
    PrintProductEntity? shopifyProduct = await shopify;
    print(shopifyProduct);

    //    // PrintProductInfoEntity? productInfoEntity =
    //     await productInfo as PrintProductInfoEntity?;
    if (shopifyProduct != null && productInfoEntity != null) onSuccess(shopifyProduct, productInfoEntity!);
  }

  // 计算图片缩放比例
  double getImageScale(double imgWidth) {
    return ScreenUtil.screenSize.width / imgWidth;
  }

  // 计算起始点位置
  Offset getOrigiPosition(double x, double y) {
    return Offset(_scale * x, _scale * y);
  }

  // 获取图片实际展示大小
  Size getImageRealSize(double width, double height) {
    return Size(width * _scale, height * _scale);
  }

  //
  // // orignal 图片中的原始点
  // // url 图片地址
  // // react大小
  // Future<Offset> tranform(Offset original, String url, Size size) async {
  //   // 获取图片的宽高
  //   ImageInfo imageInfo = await SyncNetworkImage(url: url).getImage();
  //   int imageHeight = imageInfo.image.height;
  //   int imageWidth = imageInfo.image.width;
  //   // 矩形框
  //   double reactWidth = size.width;
  //   double reactHeight = size.height;
  //   // 图片中的x y
  //   double x = original.dx;
  //   double y = original.dy;
  //
  //   // 判断充满高还是宽 /*** 这里先按照宽处理, 图片显示的宽等于矩形宽
  //   // 图片与矩形的宽高分别做比例，比例小的为所需要的缩放
  //
  //   // 计算缩放比例
  //   double sX = reactWidth / imageWidth;
  //   double sY = reactHeight / imageHeight;
  //   double scale = sX < sY ? sX : sY;
  //
  //   // 计算缩放后图片的起点
  //   double originX = (reactWidth - imageWidth * scale) / 2;
  //   double originY = (reactHeight - imageHeight * scale) / 2;
  //
  //   // 计算相对的坐标
  //   double scaleX = getNeedDouble(x * scale + originX);
  //   double scaleY = getNeedDouble(y * scale + originY);
  //
  //   print("x == $scaleX y == $scaleY");
  //
  //   return Offset(scaleX, scaleY);
  // }

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
      PrintProductDataRowsVariantsEdges edges = entity.data.rows.first.variants.edges[i];
      for (var j = 0; j < edges.node.selectedOptions.length; j++) {
        PrintProductDataRowsVariantsEdgesNodeSelectedOptions option = edges.node.selectedOptions[j];
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
