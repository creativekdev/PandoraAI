import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../Common/importFile.dart';
import '../../../images-res.dart';

typedef DateCallback = void Function(List<DateTime?> values);

class TimeSelectionSheet extends StatefulWidget {
  TimeSelectionSheet({Key? key, required this.datesCallback}) : super(key: key);
  DateCallback datesCallback;

  @override
  State<TimeSelectionSheet> createState() => _TimeSelectionSheetState();
}

class _TimeSelectionSheetState extends State<TimeSelectionSheet> {
  List<DateTime?> _dates = [];
  List<bool> _isSelected = [false, false, false];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: $(326),
      decoration: BoxDecoration(
        color: Color(0xFF1B1C1D),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular($(24)),
          topRight: Radius.circular($(24)),
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(height: $(16)),
        Row(children: [
          SizedBox(width: $(40)),
          Expanded(
            child: TitleTextWidget(
              "Order Screening".tr,
              ColorConstant.White,
              FontWeight.w400,
              $(17),
            ),
          ),
          Image.asset(
            Images.ic_avatar_bad_example,
            width: $(16),
            color: ColorConstant.White,
          )
              .intoContainer(
            padding: EdgeInsets.only(right: $(16), top: $(2)),
          )
              .intoGestureDetector(onTap: () {
            Navigator.pop(context);
          }),
        ]),
        SizedBox(height: $(20)),
        Padding(
          padding: EdgeInsets.only(left: $(15)),
          child: TitleTextWidget(
            "Order time".tr,
            ColorConstant.White,
            FontWeight.w400,
            $(14),
            align: TextAlign.left,
          ),
        ),
        SizedBox(height: $(12)),
        Container(
          height: $(40),
          margin: EdgeInsets.symmetric(horizontal: $(15)),
          child: Wrap(spacing: $(10), children: [
            timeWidget("1 month", _isSelected[0], $(108)).intoGestureDetector(onTap: () {
              _isSelected[0] = !_isSelected[0];
              _isSelected[1] = false;
              _isSelected[2] = false;
              DateTime now = DateTime.now();
              _dates = [now, now.add(Duration(days: 30))];
              setState(() {});
            }),
            timeWidget("3 month", _isSelected[1], $(108)).intoGestureDetector(onTap: () {
              _isSelected[1] = !_isSelected[1];
              _isSelected[0] = false;
              _isSelected[2] = false;
              DateTime now = DateTime.now();
              _dates = [now, now.add(Duration(days: 90))];
              setState(() {});
            }),
            timeWidget("6 month", _isSelected[2], $(108)).intoGestureDetector(onTap: () {
              _isSelected[2] = !_isSelected[2];
              _isSelected[1] = false;
              _isSelected[0] = false;
              DateTime now = DateTime.now();
              _dates = [now, now.add(Duration(days: 180))];
              setState(() {});
            }),
          ]),
        ),
        SizedBox(height: $(16)),
        Container(
          height: $(40),
          alignment: Alignment.center,
          margin: EdgeInsets.symmetric(horizontal: $(15)),
          child: Wrap(spacing: $(4), children: [
            timeWidget(
              _dates.length > 0 && _dates.first != null ? _dates.first!.toString().substring(0, 10) : "Start Date",
              false,
              $(160),
            ).intoGestureDetector(onTap: () async {
              onTapStartTimeAndEndTime();
            }),
            Container(
              margin: EdgeInsets.only(top: $(19)),
              width: $(17),
              height: $(1),
              color: Colors.white,
            ),
            timeWidget(
              _dates.length > 0 && _dates.last != null ? _dates.last!.toString().substring(0, 10) : "End Date",
              false,
              $(160),
            ).intoGestureDetector(onTap: () async {
              onTapStartTimeAndEndTime();
            }),
          ]),
        ),
        SizedBox(height: $(40)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TitleTextWidget(
              "Reset",
              ColorConstant.White,
              FontWeight.w500,
              $(17),
            )
                .intoContainer(
              alignment: Alignment.center,
              width: $(168),
              height: $(40),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular($(10)),
                ),
                border: Border.all(
                  color: ColorConstant.LightLineColor,
                ),
              ),
            )
                .intoGestureDetector(onTap: () {
              _dates = [];
              _isSelected = [false, false, false];
              setState(() {});
            }),
            TitleTextWidget(
              "Confirm",
              ColorConstant.White,
              FontWeight.w500,
              $(17),
            )
                .intoContainer(
              alignment: Alignment.center,
              width: $(168),
              height: $(40),
              decoration: BoxDecoration(
                color: Color(0xFF3E60FF),
                borderRadius: BorderRadius.all(
                  Radius.circular($(10)),
                ),
              ),
            )
                .intoGestureDetector(onTap: () {
              if (_dates.length > 0) {
                widget.datesCallback(_dates);
                Navigator.pop(context);
              } else {
                Fluttertoast.showToast(msg: "Please select date", gravity: ToastGravity.CENTER);
              }
            }),
          ],
        ).intoPadding(
          padding: EdgeInsets.symmetric(horizontal: $(15)),
        ),
      ]),
    );
  }

  onTapStartTimeAndEndTime() {
    ShowTimeSheet.show(
        context,
        Container(
          color: Color(0xFF1B1C1D),
          child: CalendarDatePicker2(
            config: CalendarDatePicker2WithActionButtonsConfig(
              calendarType: CalendarDatePicker2Type.range,
              closeDialogOnCancelTapped: true,
              selectedDayTextStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w400,
                fontSize: $(12),
              ),
              selectedDayHighlightColor: Colors.purple[800],
              dayTextStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w400,
                fontSize: $(12),
              ),
              firstDayOfWeek: 1,
              weekdayLabelTextStyle: TextStyle(
                color: ColorConstant.White,
                fontWeight: FontWeight.bold,
                fontSize: $(12),
              ),
              controlsTextStyle: TextStyle(
                color: Colors.white,
                fontSize: $(12),
                fontWeight: FontWeight.bold,
              ),
            ),
            value: _dates,
            onValueChanged: (dates) {
              if (dates.length == 2) {
                _dates = dates;
                print(_dates);
                ShowTimeSheet.hide(context);
                setState(() {});
              }
            },
          ),
        ));
  }

  Widget timeWidget(String title, bool isSelected, double width) {
    return TitleTextWidget(
      title,
      isSelected ? Color(0xFF3E60FF) : Color(0xFFF9F9F9),
      FontWeight.w400,
      $(14),
    ).intoContainer(
      width: $(108),
      height: $(40),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular($(8))),
        color: Color(0xFF0F0F0F),
        border: Border.all(
          color: isSelected ? Color(0xFF3E60FF) : Colors.transparent,
        ),
      ),
    );
  }
}

// showModalBottomSheet 显示
class ShowTimeSheet {
  // 显示
  static void show(BuildContext context, Widget child) {
    showModalBottomSheet(
      // isScrollControlled: true,
      useSafeArea: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Container(
            height: constraints.maxHeight * 1.2,
            child: child,
          );
        },
      ),
    );
  }

  // 隐藏
  static void hide(BuildContext context) {
    Navigator.pop(context);
  }
}
