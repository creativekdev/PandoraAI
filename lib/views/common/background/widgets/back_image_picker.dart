import 'package:cartoonizer/common/importFile.dart';

class BackImagePicker extends StatefulWidget {
  const BackImagePicker({super.key});

  @override
  State<BackImagePicker> createState() => _BackImagePickerState();
}

class _BackImagePickerState extends State<BackImagePicker> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      color: Colors.red,
    );
  }

  @override
  bool get wantKeepAlive => true;
}
