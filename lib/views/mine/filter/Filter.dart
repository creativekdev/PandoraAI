import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/models/enums/adjust_function.dart';
import 'package:cartoonizer/views/mine/filter/ImageProcessor.dart';

import 'package:image/image.dart' as imgLib;

enum FilterEnum { NOR, VID, VIW, VIC, DRA, DRW, DRC, MNO, SLS, CTN, INV, EDG, SHR, OLD, BLK, RMV, FUS, FRZ, CMC }

class AdjustData {
  AdjustFunction function;
  double value;
  final double initValue;
  double previousValue;
  double start;
  double end;
  bool active = false;
  double multiple;

  AdjustData({
    required this.function,
    required this.value,
    required this.previousValue,
    required this.start,
    required this.end,
    required this.initValue,
    required this.multiple,
  });

  double getProgress() {
    return (value - start) / getTotal();
  }

  double getTotal() {
    return end - start;
  }

  @override
  String toString() {
    return 'AdjustData{function: $function, value: ${value.toStringAsFixed(0)}, initValue: $initValue, previousValue: $previousValue, start: $start, end: $end}';
  }

  AdjustData copy() {
    return AdjustData(function: function, value: value, previousValue: previousValue, start: start, end: end, initValue: initValue, multiple: multiple);
  }
}

class FilterAdjustUtils {
  static List<FilterEnum> createFilters() {
    return [
      FilterEnum.NOR,
      FilterEnum.VID,
      FilterEnum.VIW,
      FilterEnum.VIC,
      FilterEnum.DRA,
      FilterEnum.DRW,
      FilterEnum.DRC,
      FilterEnum.MNO,
      FilterEnum.SLS,
      FilterEnum.CTN,
      FilterEnum.SHR,
      FilterEnum.OLD,
      FilterEnum.BLK,
      FilterEnum.RMV,
      FilterEnum.CMC,
    ];
  }

  static List<AdjustData> createAdjusts() {
    return [
      AdjustData(function: AdjustFunction.brightness, initValue: 0, value: 0, previousValue: 0, start: -20, end: 20, multiple: 5),
      AdjustData(function: AdjustFunction.contrast, initValue: 0, value: 0, previousValue: 0, start: -40, end: 40, multiple: 2.5),
      AdjustData(function: AdjustFunction.saturation, initValue: 0, value: 0, previousValue: 0, start: -40, end: 40, multiple: 2.5),
      AdjustData(function: AdjustFunction.noise, initValue: 0, value: 0, previousValue: 0, start: 0, end: 40, multiple: 0.25),
      AdjustData(function: AdjustFunction.pixelate, initValue: 0, value: 0, previousValue: 0, start: 0, end: 40, multiple: 0.5),
      AdjustData(function: AdjustFunction.blur, initValue: 0, value: 0, previousValue: 0, start: 0, end: 40, multiple: 3 / 4),
      AdjustData(function: AdjustFunction.sharpen, initValue: 0, value: 0, previousValue: 0, start: 0, end: 40, multiple: 2.5),
      AdjustData(function: AdjustFunction.hue, initValue: 0, value: 0, previousValue: 0, start: -20, end: 20, multiple: 5),
    ];
  }
}

extension FilterEnumEx on FilterEnum {
  String title() {
    switch (this) {
      case FilterEnum.NOR:
        return 'Normal';
      case FilterEnum.VID:
        return "Vivid";
      case FilterEnum.VIW:
        return 'VID Warm';
      case FilterEnum.VIC:
        return 'VID Cool';
      case FilterEnum.DRA:
        return 'Dramatic';
      case FilterEnum.DRW:
        return 'DRA Warm';
      case FilterEnum.DRC:
        return 'DRA Cool';
      case FilterEnum.MNO:
        return 'Mono';
      case FilterEnum.SLS:
        return 'Silvertone';
      case FilterEnum.CTN:
        return 'Cartoon';
      case FilterEnum.INV:
        return 'Inverse';
      case FilterEnum.EDG:
        return 'Edge';
      case FilterEnum.SHR:
        return 'Sharpen';
      case FilterEnum.OLD:
        return 'Old Time';
      case FilterEnum.BLK:
        return 'Black White';
      case FilterEnum.RMV:
        return 'Remove Color';
      case FilterEnum.FUS:
        return 'Fused';
      case FilterEnum.FRZ:
        return 'Freeze';
      case FilterEnum.CMC:
        return 'Comic';
    }
  }
}

@deprecated
class Filter {
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
            if (avg > 100)
              avg = 255;
            else
              avg = 0;
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
            HSVColor hsv = HSVColor.fromColor(Color.fromARGB(alpha, red, green, blue));
            hsv = hsv.withSaturation((hsv.saturation * 1.5).clamp(0, 1));
            Color color = hsv.toColor();
            // Convert the HSL color back to RGB

            // Set the new color for the pixel
            res_image.setPixelRgba(
              x,
              y,
              color.red.clamp(0, 255),
              color.green.clamp(0, 255),
              color.blue.clamp(0, 255),
            );
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
            HSVColor hsv = HSVColor.fromColor(Color.fromARGB(alpha, red, green, blue));

            hsv = hsv.withSaturation((hsv.saturation * 1.5).clamp(0, 1));
            Color color = hsv.toColor();
            res_image.setPixelRgba(x, y, (color.red + 25).round().clamp(0, 255), (color.green + 20).round().clamp(0, 255), color.blue);
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
            HSVColor hsv = HSVColor.fromColor(Color.fromARGB(alpha, red, green, blue));

            hsv = hsv.withSaturation((hsv.saturation * 1.5).clamp(0, 1));
            Color color = hsv.toColor();
            res_image.setPixelRgba(x, y, color.red, (color.green + 20).round().clamp(0, 255), (color.blue + 25).round().clamp(0, 255));
          }
        }
        break;
      case "DRA":
        // Apply the dramatic filter
        imgLib.contrast(res_image, 120);
        break;
      case "DRW":
        // Apply the dramatic warm filter
        imgLib.contrast(res_image, 120);
        for (int x = 0; x < res_image.width; x++) {
          for (int y = 0; y < res_image.height; y++) {
            final pixel = res_image.getPixel(x, y);

            // Modify the pixel values to create the dramatic warm effect
            final red = imgLib.getRed(pixel);
            final green = imgLib.getGreen(pixel);
            final blue = imgLib.getBlue(pixel);

            res_image.setPixelRgba(x, y, (red + 25).clamp(0, 255).toInt(), (green + 20).clamp(0, 255).toInt(), blue);
          }
        }
        break;
      case "DRC":
        // Apply the dramatic cool filter
        imgLib.contrast(res_image, 120);
        for (int x = 0; x < res_image.width; x++) {
          for (int y = 0; y < res_image.height; y++) {
            final pixel = res_image.getPixel(x, y);

            // Modify the pixel values to create the dramatic cool effect
            final red = imgLib.getRed(pixel);
            final green = imgLib.getGreen(pixel);
            final blue = imgLib.getBlue(pixel);

            res_image.setPixelRgba(x, y, red, (green + 20).clamp(0, 255).toInt(), (blue + 25).clamp(0, 255).toInt());
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
      case "CTN":
        // imgLib;
        List<int> group = [];
        List<int> cnt = [];
        // res_image = imgLib.bilateralFilter(res_image, sigmaSpace: 4, sigmaColor: 8);
        for (int x = 0; x < res_image.width; x++) {
          for (int y = 0; y < res_image.height; y++) {
            final pixel = res_image.getPixel(x, y);
            final red = imgLib.getRed(pixel);
            final green = imgLib.getGreen(pixel);
            final blue = imgLib.getBlue(pixel);
            int k;
            for (k = 0; k < group.length; k++) {
              final pixel2 = group[k];
              final r = imgLib.getRed(pixel2);
              final g = imgLib.getGreen(pixel2);
              final b = imgLib.getBlue(pixel2);
              int dr = r - red;
              int dg = g - green;
              int db = b - blue;
              if ((dr * dr + dg * dg + db * db) < 6000) {
                int rr = (red * cnt[k] + r) ~/ (cnt[k] + 1);
                int gg = (green * cnt[k] + g) ~/ (cnt[k] + 1);
                int bb = (blue * cnt[k] + b) ~/ (cnt[k] + 1);

                group[k] = imgLib.getColor(rr, gg, bb);
                cnt[k]++;
                break;
              }
            }
            if (k == group.length) {
              group.add(pixel);
              cnt.add(0);
            }
          }
        }
        for (int x = 0; x < res_image.width; x++) {
          for (int y = 0; y < res_image.height; y++) {
            final int pixel = res_image.getPixel(x, y);
            int mink = 0;
            for (int k = 0; k < group.length; k++) {
              final r1 = imgLib.getRed(pixel);
              final g1 = imgLib.getGreen(pixel);
              final b1 = imgLib.getBlue(pixel);
              final r2 = imgLib.getRed(group[k]);
              final g2 = imgLib.getGreen(group[k]);
              final b2 = imgLib.getBlue(group[k]);
              final r3 = imgLib.getRed(group[mink]);
              final g3 = imgLib.getGreen(group[mink]);
              final b3 = imgLib.getBlue(group[mink]);
              int dr1 = r1 - r2;
              int dg1 = g1 - g2;
              int db1 = b1 - b2;
              int dr2 = r1 - r3;
              int dg2 = g1 - g3;
              int db2 = b1 - b3;
              if ((dr1 * dr1 + dg1 * dg1 + db1 * db1) < (dr2 * dr2 + dg2 * dg2 + db2 * db2)) mink = k;
            }
            // Convert the pixel to grayscale
            final red = imgLib.getRed(group[mink]);
            final green = imgLib.getGreen(group[mink]);
            final blue = imgLib.getBlue(group[mink]);

            final modifiedPixel = imgLib.getColor(red, green, blue);
            res_image.setPixel(x, y, modifiedPixel);
          }
        }

        break;
      default:
    }
    return res_image;
  }
}
