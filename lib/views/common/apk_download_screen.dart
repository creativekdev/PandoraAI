import 'dart:io';

import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/progress/progress_bar.dart';
import 'package:cartoonizer/Widgets/router/routers.dart';
import 'package:cartoonizer/api/downloader.dart';

class ApkDownloadScreen extends StatefulWidget {
  static Future<bool?> start(
    BuildContext context, {
    required String url,
    required String filePath,
    required bool force,
  }) async {
    return Navigator.of(context).push<bool>(NoAnimRouter(
        ApkDownloadScreen(
          url: url,
          filePath: filePath,
          force: force,
        ),
        settings: RouteSettings(name: '/ApkDownloadScreen')));
  }

  String url;
  String filePath;
  bool force;

  ApkDownloadScreen({
    super.key,
    required this.filePath,
    required this.url,
    required this.force,
  });

  @override
  State<ApkDownloadScreen> createState() => _ApkDownloadScreenState();
}

class _ApkDownloadScreenState extends State<ApkDownloadScreen> {
  int progress = 0;
  DownloadListener? downloadListener;
  String? key;

  @override
  void initState() {
    super.initState();
    File data = File(widget.filePath);
    if (data.existsSync()) {
      progress = 1000;
      delay(() {
        Navigator.of(context).pop(true);
      }, milliseconds: 100);
    } else {
      progress = 0;
      downloadListener = DownloadListener(onChanged: (count, total) {
        if (mounted) {
          setState(() {
            double d = (count.toDouble() / total.toDouble());
            progress = (d * 1000).toInt();
          });
        }
      }, onError: (error) {
        Downloader.instance.unsubscribeSync(key!, downloadListener!);
        Navigator.of(context).pop(false);
      }, onFinished: (File file) {
        file.rename(widget.filePath).then((value) {
          Navigator.of(context).pop(true);
        });
      });
      Downloader.instance.download(widget.url, widget.filePath + '.tmp').then((value) {
        key = value;
        Downloader.instance.subscribe(value, downloadListener!);
      });
    }
  }

  @override
  void dispose() {
    if (key != null && downloadListener != null) {
      Downloader.instance.unsubscribeSync(key!, downloadListener!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: (ScreenUtil.screenSize.width - $(130)) / 2,
              height: $(40),
              color: Colors.transparent,
            ).intoGestureDetector(onTap: () {
              if (widget.force) {
                return;
              }
              Downloader.instance.cancel(key ?? '');
              Navigator.of(context).pop(false);
            }),
            SizedBox(
              height: $(30),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: AppProgressBar(
                progress: progress,
              ),
            ),
          ],
        )
            .intoContainer(
              margin: EdgeInsets.only(top: $(285), left: $(60), right: $(60)),
            )
            .intoCenter(),
        onWillPop: () async {
          if (widget.force) {
            return false;
          } else {
            return true;
          }
        });
  }
}
