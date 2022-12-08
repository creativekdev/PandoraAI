import 'package:cartoonizer/Common/Extension.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';

enum Gender {
  male,
  female,
  other,
}

extension GenderEx on Gender {
  title() {
    switch (this) {
      case Gender.male:
        return 'Male';
      case Gender.female:
        return 'Female';
      case Gender.other:
        return 'Other';
    }
  }
}

class SelectGenderScreen {
  static Future<Gender?> push(BuildContext context, {Gender? gender}) {
    return Navigator.of(context).push<Gender>(MaterialPageRoute(
      builder: (context) => _SelectGenderScreen(gender: gender),
    ));
  }
}

class _SelectGenderScreen extends StatefulWidget {
  Gender? gender;

  _SelectGenderScreen({
    Key? key,
    this.gender,
  }) : super(key: key);

  @override
  State<_SelectGenderScreen> createState() => _SelectGenderScreenState();
}

class _SelectGenderScreenState extends State<_SelectGenderScreen> {
  Gender? gender;
  List<Gender> genders = [
    Gender.male,
    Gender.female,
    Gender.other,
  ];

  @override
  void initState() {
    super.initState();
    gender = widget.gender;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ColorConstant.BackgroundColor,
        appBar: AppNavigationBar(
          backgroundColor: ColorConstant.BackgroundColor,
          middle: TitleTextWidget('Select Gender', ColorConstant.White, FontWeight.w600, $(17)),
        ),
        body: Column(
          children: [
            Expanded(
              child: Column(
                children: genders.map((e) {
                  bool checked = e == gender;
                  return Row(
                    children: [
                      Icon(
                        checked ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                        color: ColorConstant.White,
                      ),
                      SizedBox(width: $(12)),
                      Text(
                        e.title(),
                        style: TextStyle(
                          color: ColorConstant.White,
                          fontSize: $(19),
                        ),
                      )
                    ],
                  )
                      .intoContainer(
                        padding: EdgeInsets.symmetric(horizontal: $(25), vertical: $(25)),
                      )
                      .intoMaterial(
                        elevation: 4,
                        color: checked ? ColorConstant.BlueColor : ColorConstant.CardColor,
                        borderRadius: BorderRadius.circular($(8)),
                      )
                      .intoGestureDetector(onTap: () {
                    setState(() {
                      gender = e;
                    });
                  }).intoContainer(
                          margin: EdgeInsets.symmetric(
                    vertical: $(10),
                    horizontal: $(30),
                  ));
                }).toList(),
              ),
            ),
            Text(
              'Ok',
              style: TextStyle(color: Colors.white),
            )
                .intoContainer(
              padding: EdgeInsets.symmetric(vertical: $(12)),
              margin: EdgeInsets.symmetric(horizontal: $(15), vertical: $(15)),
              width: double.maxFinite,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular($(32)),
                color: ColorConstant.BlueColor,
              ),
            )
                .intoGestureDetector(onTap: () {
              if (gender == null) {
                CommonExtension().showToast('Please select your gender');
              } else {
                Navigator.of(context).pop(gender);
              }
            })
          ],
        ));
  }
}
