import '../common/importFile.dart';

class AutomaticKeepAliveWidget extends StatefulWidget {
  final Widget child;

  const AutomaticKeepAliveWidget({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<AutomaticKeepAliveWidget> createState() => _AutomaticKeepAliveState();
}

class _AutomaticKeepAliveState extends State<AutomaticKeepAliveWidget> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }

  @override
  bool get wantKeepAlive => true;
}
