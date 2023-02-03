class OfflineEffectModel {
  String data = "";
  String imageUrl = "";
  String message = "";
  bool hasWatermark;
  bool localVideo;

  OfflineEffectModel({
    required this.data,
    required this.imageUrl,
    required this.message,
    required this.hasWatermark,
    this.localVideo = false,
  });
}
