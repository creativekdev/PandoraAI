import 'package:ffmpeg_kit_flutter/ffprobe_kit.dart';

class FFmpegUtil {
  ///
  /// @Author: wangyu
  /// @Date: 2023/2/22
  ///
  static String commandImage2Video({
    required String mainDir,
    required String outputPath,
    int framePerSecond = 24,
  }) {
    return '-y -framerate $framePerSecond -i "$mainDir/%1d.png" -b:v 768k -vcodec mpeg4 "$outputPath"';
  }

  static String commandVideoToInstagram({
    required String originFile,
    required String targetFile,
  }) {
    return '-i "$originFile" -vf scale=640:640 "$targetFile"';
  }

  static Future<double?> getVideoRatio(String filePath) async {
    var session = await FFprobeKit.getMediaInformation(filePath);
    var mediaInfo = session.getMediaInformation();
    if (mediaInfo == null) {
      return null;
    }
    var streams = mediaInfo.getStreams();
    for (var value in streams) {
      var aspectRatio = value.getDisplayAspectRatio();
      if ((aspectRatio != null)) {
        var split = aspectRatio.toString().split(":");
        if (split.length == 2) {
          double width = double.parse(split[0]);
          double height = double.parse(split[1]);
          return width / height;
        }
      }
    }
    return null;
  }
}
