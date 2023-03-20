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
}
