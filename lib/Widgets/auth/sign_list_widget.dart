import 'dart:io';

import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/images-res.dart';

enum ThirdPartAccount {
  apple,
  google,
  youtube,
  instagram,
  tiktok,
}

extension ThirdPartAccountEx on ThirdPartAccount {
  String image() {
    switch (this) {
      case ThirdPartAccount.apple:
        return Images.ic_sign_apple;
      case ThirdPartAccount.google:
        return Images.ic_sign_google;
      case ThirdPartAccount.youtube:
        return Images.ic_sign_youtube;
      case ThirdPartAccount.instagram:
        return Images.ic_sign_instagram;
      case ThirdPartAccount.tiktok:
        return Images.ic_sign_tiktok;
    }
  }
}

class SignListWidget extends StatelessWidget {
  Function(ThirdPartAccount account) onTap;
  late List<ThirdPartAccount> thirdPart;

  SignListWidget({
    Key? key,
    required this.onTap,
    List<ThirdPartAccount>? thirdPart,
  }) : super(key: key) {
    this.thirdPart = thirdPart ??
        [
          ThirdPartAccount.google,
          ThirdPartAccount.apple,
        ];
    if (!Platform.isIOS) {
      this.thirdPart.remove(ThirdPartAccount.apple);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: thirdPart
          .map((e) => Expanded(
                child: Image.asset(
                  e.image(),
                  width: $(28),
                ).intoGestureDetector(onTap: () {
                  onTap.call(e);
                }).intoContainer(alignment: Alignment.center),
              ))
          .toList(),
    );
  }
}
