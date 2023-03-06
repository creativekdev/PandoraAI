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
    return '-y -r $framePerSecond -f image2 -i "$mainDir/%d.png" -b:v 4096k -c:v mpeg4 "$outputPath"';
  }
}
