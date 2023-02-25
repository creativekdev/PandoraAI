class FFmpegUtil {
  ///
  /// @Author: wangyu
  /// @Date: 2023/2/22
  ///
  static String commandImage2Video({
    required String mainDir,
    String? outputDir,
    int framePerSecond = 24,
  }) {
    if (outputDir == null) {
      outputDir = mainDir;
    }
    return '-f image2 -i "$mainDir/%d.png" -b:v 1536k "$outputDir/output.mp4"';
    // return '-f image2 -i $mainDir/%d.png -r $framePerSecond -b:v 4M -s 480x640 $outputDir/output.mp4';
  }
}
