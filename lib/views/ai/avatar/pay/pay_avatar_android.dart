import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/views/StripePaymentScreen.dart';

class PayAvatarAndroid {
  String planId;

  PayAvatarAndroid({required this.planId});

  startPay(BuildContext context, Function(bool result) callback) async {
    Navigator.of(context)
        .push(MaterialPageRoute(
      settings: RouteSettings(name: '/StripePaymentScreen'),
      builder: (context) => StripePaymentScreen(planId: planId, buySingle: true),
    ))
        .then((value) {
      var paymentResult = GetStorage().read('payment_result');
      if (paymentResult != null && paymentResult as bool == true) {
        GetStorage().remove("payment_result");
        callback.call(true);
      } else {
        callback.call(false);
      }
    });
  }
}
