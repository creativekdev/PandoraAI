import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/views/mine/filter/ImageProcessor.dart';


import 'package:image/image.dart' as imgLib;

class Filter{
  int selectedID = 0;
  static List<String> filters = [
    "NOR",
    "INV",
    "EDG",
    "SHR",
    "OLD",
    "BLK",
    "RMV",
    "FUS",
    "FRZ",
    "CMC",
    "VID",
    "VIW",
    "VIC",
    "DRA",
    "DRW",
    "DRC",
    "MNO",
    "SLS",
    "NOI"
  ];
  void setSelectedID(int id) {
    selectedID = id;
  }
  int getSelectedID() {
    return selectedID;
  }
  List<Uint8List> avatars = [];
  Future<bool> calcAvatars(imgLib.Image _image) async {
    int _width, _height;
    int st_width, st_height;
    if(_image.height > _image.width) {
      st_width = 0;
      st_height = (_image.height - _image.width) ~/ 2;
    _height = _image.width;
    _width = _image.width;
    } else {
      _width = _image.height;
      _height =_image.height;
      st_width = (_image.width - _image.height) ~/ 2;;
      st_height = 0;
    }
    imgLib.Image cropedImage = imgLib.copyCrop(_image,st_width ,st_height, _width, _height );
    imgLib.Image resizedImage = imgLib.copyResize(cropedImage, width:$(60).toInt(), height: $(60).toInt());
    avatars.clear();
    for(String filter in filters) {
      avatars.add(Uint8List.fromList(imgLib.encodeJpg(await ImFilter(filter,resizedImage))));
    }
    return true;
  }
  static Future<imgLib.Image> ImFilter(String filter, imgLib.Image _image) async {
    //uncomment when image_picker is installed
    imgLib.Image res_image;
    res_image = imgLib.copyCrop(_image, 0, 0, _image.width, _image.height);
    switch (filter) {
      case "NOR":
        break;
      case "INV":
        for (int i = 0; i < res_image.width; i++) {
          for (int j = 0; j < res_image.height; j++) {
            var pixel = res_image.getPixel(i, j);
            int r = ImageProcessor.getR(pixel);
            int g = ImageProcessor.getG(pixel);
            int b = ImageProcessor.getB(pixel);
            r = 255 - r;
            g = 255 - g;
            b = 255 - b;
            pixel = ImageProcessor.setRGB(pixel, r, g, b);
            res_image.setPixel(i, j, pixel);
          }
        }
        break;
      case "EDG":
        List<int> kernel = [-1, -1, -1, -1, 8, -1, -1, -1, -1];
        res_image = ImageProcessor.convolution(res_image, kernel);
        break;
      case "SHR":
        List<int> kernel = [-1, -1, -1, -1, 9, -1, -1, -1, -1];
        res_image = ImageProcessor.convolution(res_image, kernel);
        break;
      case "OLD":
        for (int i = 0; i < res_image.width; i++) {
          for (int j = 0; j < res_image.height; j++) {
            var pixel = res_image.getPixel(i, j);
            int r = ImageProcessor.getR(pixel);
            int g = ImageProcessor.getG(pixel);
            int b = ImageProcessor.getB(pixel);
            int newR = (0.393 * r + 0.769 * g + 0.189 * b).toInt();
            int newG = (0.349 * r + 0.686 * g + 0.168 * b).toInt();
            int newB = (0.272 * r + 0.534 * g + 0.131 * b).toInt();
            pixel = ImageProcessor.setRGB(pixel, newR, newG, newB);
            res_image.setPixel(i, j, pixel);
          }
        }
        break;
      case "BLK":
        for (int i = 0; i < res_image.width; i++) {
          for (int j = 0; j < res_image.height; j++) {
            var pixel = res_image.getPixel(i, j);
            int r = ImageProcessor.getR(pixel);
            int g = ImageProcessor.getG(pixel);
            int b = ImageProcessor.getB(pixel);
            int avg = (r + g + b).toDouble() ~/ 3;
            if(avg>100) avg = 255;
            else avg = 0;
            int newR = avg;
            int newG = avg;
            int newB = avg;
            pixel = ImageProcessor.setRGB(pixel, newR, newG, newB);
            res_image.setPixel(i, j, pixel);
          }
        }
        break;
      case "RMV":
        for (int i = 0; i < res_image.width; i++) {
          for (int j = 0; j < res_image.height; j++) {
            var pixel = res_image.getPixel(i, j);
            int r = ImageProcessor.getR(pixel);
            int g = ImageProcessor.getG(pixel);
            int b = ImageProcessor.getB(pixel);
            int avg = (r + g + b).toDouble() ~/ 3;
            int newR = avg;
            int newG = avg;
            int newB = avg;
            pixel = ImageProcessor.setRGB(pixel, newR, newG, newB);
            res_image.setPixel(i, j, pixel);
          }
        }
        break;
      case "FUS":
        for (int i = 0; i < res_image.width; i++) {
          for (int j = 0; j < res_image.height; j++) {
            var pixel = res_image.getPixel(i, j);
            int r = ImageProcessor.getR(pixel);
            int g = ImageProcessor.getG(pixel);
            int b = ImageProcessor.getB(pixel);
            int newR = ((r * 128) / (g + b + 1)).toInt();
            int newG = ((g * 128) / (r + b + 1)).toInt();
            int newB = ((b * 128) / (g + r + 1)).toInt();
            pixel = ImageProcessor.setRGB(pixel, newR, newG, newB);
            res_image.setPixel(i, j, pixel);
          }
        }
        break;
      case "FRZ":
        for (int i = 0; i < res_image.width; i++) {
          for (int j = 0; j < res_image.height; j++) {
            var pixel = res_image.getPixel(i, j);
            int r = ImageProcessor.getR(pixel);
            int g = ImageProcessor.getG(pixel);
            int b = ImageProcessor.getB(pixel);
            int newR = (((r - g - b) * 3) / 2).toInt();
            int newG = (((g - r - b) * 3) / 2).toInt();
            int newB = (((b - g - r) * 3) / 2).toInt();
            pixel = ImageProcessor.setRGB(pixel, newR, newG, newB);
            res_image.setPixel(i, j, pixel);
          }
        }
        break;
      case "CMC":
        for (int i = 0; i < res_image.width; i++) {
          for (int j = 0; j < res_image.height; j++) {
            var pixel = res_image.getPixel(i, j);
            int r = ImageProcessor.getR(pixel);
            int g = ImageProcessor.getG(pixel);
            int b = ImageProcessor.getB(pixel);
            int newR = (((g - b + g + r).abs() * r) / 256).toInt();
            int newG = (((b - g + b + r).abs() * r) / 256).toInt();
            int newB = (((b - g + b + r).abs() * g) / 256).toInt();
            pixel = ImageProcessor.setRGB(pixel, newR, newG, newB);
            res_image.setPixel(i, j, pixel);
          }
        }
        break;
      case "VID":
        for (int x = 0; x < res_image.width; x++) {
          for (int y = 0; y < res_image.height; y++) {
            // Get the pixel color at (x, y)
            int pixel = res_image.getPixel(x, y);

            // Extract the red, green, and blue channels from the pixel
            int red = imgLib.getRed(pixel);
            int green = imgLib.getGreen(pixel);
            int blue = imgLib.getBlue(pixel);
            int alpha = imgLib.getAlpha(pixel);

            // Apply the vivid effect by increasing the saturation
            HSLColor hslColor = HSLColor.fromColor( Color.fromARGB(alpha, red, green, blue));
            hslColor = hslColor.withSaturation(0.8);
            Color color = hslColor.toColor();

            // Convert the HSL color back to RGB

            // Set the new color for the pixel
            res_image.setPixelRgba(x, y, color.red, color.green, color.blue);
          }
        }

        break;
      case "VIW":
        for (int x = 0; x < res_image.width; x++) {
          for (int y = 0; y < res_image.height; y++) {
            // Get the pixel color at (x, y)
            int pixel = res_image.getPixel(x, y);

            // Extract the red, green, and blue channels from the pixel
            int red = imgLib.getRed(pixel);
            int green = imgLib.getGreen(pixel);
            int blue = imgLib.getBlue(pixel);
            int alpha = imgLib.getAlpha(pixel);

            res_image.setPixelRgba(x, y, (red * 1.8).round().clamp(0, 255),(green * 1.8).round().clamp(0, 255),blue);
          }
        }
        break;
      case "VIC":
        for (int x = 0; x < res_image.width; x++) {
          for (int y = 0; y < res_image.height; y++) {
            // Get the pixel color at (x, y)
            int pixel = res_image.getPixel(x, y);

            // Extract the red, green, and blue channels from the pixel
            int red = imgLib.getRed(pixel);
            int green = imgLib.getGreen(pixel);
            int blue = imgLib.getBlue(pixel);
            int alpha = imgLib.getAlpha(pixel);

            res_image.setPixelRgba(x, y, red,(green * 1.8).round().clamp(0, 255),(blue * 1.8).round().clamp(0, 255));
          }
        }
        break;
      case "DRA":

      // Apply the dramatic filter
        for (int x = 0; x < res_image.width; x++) {
          for (int y = 0; y < res_image.height; y++) {
            final pixel = res_image.getPixel(x, y);

            // Modify the pixel values to create the dramatic effect
            final red = imgLib.getRed(pixel);
            final green = imgLib.getGreen(pixel);
            final blue = imgLib.getBlue(pixel);

            int modifiedRed = (red * 2).clamp(0, 255);
            int modifiedGreen = (green * 0.8).clamp(0, 255).toInt();
            int modifiedBlue = (blue * 1.5).clamp(0, 255).toInt();

            res_image.setPixelRgba(x, y, modifiedRed, modifiedGreen, modifiedBlue);
          }
        }
        break;
      case "DRW":
      // Apply the dramatic warm filter
        for (int x = 0; x < res_image.width; x++) {
          for (int y = 0; y < res_image.height; y++) {
            final pixel = res_image.getPixel(x, y);

            // Modify the pixel values to create the dramatic warm effect
            final red = imgLib.getRed(pixel);
            final green = imgLib.getGreen(pixel);
            final blue = imgLib.getBlue(pixel);

            int modifiedRed = (red * 1.5).clamp(0, 255).toInt(); // Increase red channel intensity
            int modifiedGreen = (green * 0.8).clamp(0, 255).toInt(); // Decrease green channel intensity
            int modifiedBlue = (blue * 0.8).clamp(0, 255).toInt(); // Decrease blue channel intensity

            res_image.setPixelRgba(x, y, modifiedRed, modifiedGreen, modifiedBlue);
          }
        }
        break;
      case "DRC":

      // Apply the dramatic cool filter
        for (int x = 0; x < res_image.width; x++) {
          for (int y = 0; y < res_image.height; y++) {
            final pixel = res_image.getPixel(x, y);

            // Modify the pixel values to create the dramatic cool effect
            final red = imgLib.getRed(pixel);
            final green = imgLib.getGreen(pixel);
            final blue = imgLib.getBlue(pixel);

            final modifiedRed = (red * 0.8).clamp(0, 255).toInt(); // Decrease red channel intensity
            final modifiedGreen = (green * 0.8).clamp(0, 255).toInt(); // Decrease green channel intensity
            final modifiedBlue = (blue * 1.5).clamp(0, 255).toInt(); // Increase blue channel intensity

            res_image.setPixelRgba(x, y, modifiedRed, modifiedGreen, modifiedBlue);
          }
        }
        break;
      case "MNO":
        for (int x = 0; x < res_image.width; x++) {
          for (int y = 0; y < res_image.height; y++) {
            final pixel = res_image.getPixel(x, y);

            // Convert the pixel to grayscale
            final luminance = imgLib.getLuminance(pixel);
            final modifiedPixel = imgLib.getColor(luminance, luminance, luminance);

            res_image.setPixel(x, y, modifiedPixel);
          }
        }
        break;
      case "SLS":
      // Apply the Silverstone filter
        for (int x = 0; x < res_image.width; x++) {
          for (int y = 0; y < res_image.height; y++) {
            final pixel = res_image.getPixel(x, y);

            // Modify the pixel values to create the Silverstone effect
            final red = imgLib.getRed(pixel);
            final green = imgLib.getGreen(pixel);
            final blue = imgLib.getBlue(pixel);

            final modifiedRed = (red * 0.7).clamp(0, 255).toInt(); // Decrease red channel intensity
            final modifiedGreen = (green * 0.7).clamp(0, 255).toInt(); // Decrease green channel intensity
            final modifiedBlue = (blue * 0.9).clamp(0, 255).toInt(); // Decrease blue channel intensity

            final modifiedPixel = imgLib.getColor(modifiedRed, modifiedGreen, modifiedBlue);
            res_image.setPixel(x, y, modifiedPixel);
          }
        }
        break;
      case "NOI":
      // Apply the Noir filter
        for (int x = 0; x < res_image.width; x++) {
          for (int y = 0; y < res_image.height; y++) {
            final pixel = res_image.getPixel(x, y);

            // Convert the pixel to grayscale
            final luminance = imgLib.getLuminance(pixel);
            final modifiedPixel = imgLib.getColor(luminance, luminance, luminance);

            res_image.setPixel(x, y, modifiedPixel);
          }
        }

        break;
      default:
    }
    return res_image;
  }
}