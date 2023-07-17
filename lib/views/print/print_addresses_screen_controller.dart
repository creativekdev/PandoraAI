import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/api/cartoonizer_api.dart';

import '../../models/address_entity.dart';

class PrintAddressesScreenController extends GetxController {
  late CartoonizerApi cartoonizerApi;
  late StreamSubscription onDeleteListener;
  late StreamSubscription onUpdateListener;
  late StreamSubscription onAddListener;

  late List<AddressDataCustomerAddress> addresses;

  onSuccess() {
    update();
  }

  @override
  void onInit() {
    super.onInit();
    cartoonizerApi = CartoonizerApi().bindController(this);
    onDeleteListener = EventBusHelper().eventBus.on<OnDeletePrintAddressEvent>().listen((event) {
      for (var value in addresses) {
        if (value.id == event.data) {
          addresses.remove(value);
          break;
        }
      }
      update();
    });

    onUpdateListener = EventBusHelper().eventBus.on<OnUpdatePrintAddressEvent>().listen((event) {
      for (int i = 0; i < addresses.length; i++) {
        AddressDataCustomerAddress value = addresses[i];
        if (value.id == event.data?.id) {
          addresses[i] = event.data!;
          break;
        }
      }
      update();
    });

    onAddListener = EventBusHelper().eventBus.on<OnAddPrintAddressEvent>().listen((event) {
      if (event.data != null) {
        addresses.add(event.data!);
      }
      update();
    });
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void dispose() {
    super.dispose();
    cartoonizerApi.unbind();
    onDeleteListener.cancel();
    onAddListener.cancel();
    onUpdateListener.cancel();
  }
}