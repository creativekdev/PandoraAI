import 'package:cartoonizer/Common/importFile.dart';

export 'package:cartoonizer/Common/StringConstant.dart';

// Common Dialog
class CommonDialog extends StatefulWidget {
  final double? height;
  final String? title;
  final String? content;
  final String? confirmContent;
  final Color? confirmTextColor;
  final bool isCancel;
  final Color? confirmColor;
  final Color? cancelColor;
  final bool barrierDismissible;
  final bool dismissAfterConfirm;
  final Function? confirmCallback;
  final Function? dismissCallback;

  final String? image;
  final String? imageHintText;

  const CommonDialog({
    Key? key,
    this.height = 180,
    this.title,
    this.content,
    this.confirmContent,
    this.confirmTextColor,
    this.isCancel = true,
    this.confirmColor,
    this.cancelColor,
    this.barrierDismissible = true,
    this.dismissAfterConfirm = true,
    this.confirmCallback,
    this.dismissCallback,
    this.image,
    this.imageHintText,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _CommonDialogState();
  }
}

class _CommonDialogState extends State<CommonDialog> {
  _confirmDialog() {
    if (widget.dismissAfterConfirm) {
      _dismissDialog();
    }
    if (widget.confirmCallback != null) {
      widget.confirmCallback!();
    }
  }

  _dismissDialog() {
    if (widget.dismissCallback != null) {
      widget.dismissCallback!();
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    // final size = MediaQuery.of(context).size;
    // final width = size.width;

    var confirmPadding = widget.isCancel ? 0.w : 10.w;

    Column _columnText = Column(
      children: <Widget>[
        widget.title == null
            ? Container()
            : Padding(
                padding: EdgeInsets.only(top: 8, bottom: 8),
                child: Text(widget.title ?? "", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500), textAlign: TextAlign.center)),
        Expanded(
          child: Center(
            child: Padding(
              padding: EdgeInsets.only(left: 4.w, right: 4.w),
              child: Text(
                widget.content == null ? '' : widget.content!,
                style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500, height: 1.3),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          flex: 1,
        ),
        widget.image == null
            ? Container()
            : Padding(padding: EdgeInsets.only(top: 12, bottom: 12), child: Image(image: AssetImage(widget.image == null ? '' : widget.image!), width: 48.0, height: 48.0)),
        SizedBox(height: 16),
        Container(
            child: Row(
          children: <Widget>[
            Expanded(
                child: widget.isCancel
                    ? SizedBox(
                        height: 40,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            // primary: Color(0xFFDCDDDE),
                            splashFactory: NoSplash.splashFactory,
                            backgroundColor: widget.cancelColor == null ? Color(0xFFDCDDDE) : widget.cancelColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(StringConstant.cancel,
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w600,
                                color: widget.cancelColor == null ? Color.fromRGBO(0, 0, 0, 0.54) : widget.cancelColor,
                              )),
                          onPressed: _dismissDialog,
                        ),
                      )
                    : Container(),
                flex: widget.isCancel ? 1 : 0),
            SizedBox(width: widget.isCancel ? 14.0 : 0),
            Expanded(
                child: SizedBox(
                  height: 40,
                  child: Padding(
                    padding: EdgeInsets.only(left: confirmPadding, right: confirmPadding),
                    child: TextButton(
                      style: TextButton.styleFrom(
                        // primary: Color(0xFF4458FB),
                        splashFactory: NoSplash.splashFactory,
                        backgroundColor: widget.confirmColor == null ? Color(0xFF4458FB) : widget.confirmColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(widget.confirmContent == null ? StringConstant.confirm : widget.confirmContent!,
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                            color: widget.confirmColor == null ? (widget.confirmTextColor == null ? Colors.white : widget.confirmTextColor) : Color(0xFFFFFFFF),
                          )),
                      onPressed: _confirmDialog,
                    ),
                  ),
                ),
                flex: 1),
          ],
        ))
      ],
    );

    return WillPopScope(
      onWillPop: () async => widget.barrierDismissible,
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        content: Container(
          width: 320,
          height: widget.height,
          alignment: Alignment.center,
          child: _columnText,
        ),
      ),
    );
  }
}
