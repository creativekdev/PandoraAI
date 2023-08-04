import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';

class ColorUtil {
  static String colorValueAlphabet = '0123456789abcdef';

  static List<String> matchColorStrings(String htmlString) {
    RegExp _reg1 = RegExp(r'color:\s*(?:#([0-9a-fA-F]{3}|[0-9a-fA-F]{4}|[0-9a-fA-F]{6}|[0-9a-fA-F]{8})|([a-zA-Z]+))');
    RegExp _reg2 = RegExp(r'color:\s*rgba?\(\s*\d+\s*,\s*\d+\s*,\s*\d+\s*(?:,\s*\d+\s*)?\)');
    RegExp _reg3 = RegExp(r'color:\s*rgba\((?:[^()]*|\((?:[^()]*|\([^()]*\))*\))*\)');
    return [..._matchColorStrings(htmlString, _reg1), ..._matchColorStrings(htmlString, _reg2), ..._matchColorStrings(htmlString, _reg3)];
  }

  static List<String> _matchColorStrings(String htmlString, RegExp reg) {
    var allMatches = reg.allMatches(htmlString ?? '').toList();
    if (allMatches.isEmpty) {
      return [];
    }
    Set<String> result = {};
    for (var value in allMatches) {
      var imgTag = value.group(0) ?? '';
      result.add(imgTag);
    }
    return result.toList();
  }

  static List<String> matchImageUrl(String htmlString) {
    RegExp _reg = RegExp('<(img|IMG)(.*?)/>');
    var allMatches = _reg.allMatches(htmlString ?? '').toList();
    if (allMatches.isEmpty) {
      return [];
    }
    List<String> result = [];
    for (var value in allMatches) {
      var imgTag = value.group(0) ?? '';
      RegExp urlReg = RegExp('(src|SRC)=\"(.*?)\"');
      var imgMatchers = urlReg.allMatches(imgTag).toList();
      if (!imgMatchers.isEmpty) {
        var srcStr = imgMatchers[0].group(0) ?? '';
        var split = srcStr.split('=');
        if (split.length == 2) {
          result.add(split[1].replaceAll('\"', ''));
        }
      }
    }
    return result;
  }

  static String invertColor(String color) {
    if (color.startsWith('color: rgb')) {
      return invertRgb(color);
    } else {
      return invertColorHex(color);
    }
  }

  static String invertColorHex(String color) {
    RegExp regex = RegExp(r'color:\s*(?:#([0-9a-fA-F]{3}|[0-9a-fA-F]{4}|[0-9a-fA-F]{6}|[0-9a-fA-F]{8})|([a-zA-Z]+))');

    if (!regex.hasMatch(color)) {
      return '';
    }

    RegExpMatch match = regex.firstMatch(color)!;

    String? hex = match.group(1);
    String? word = match.group(2);

    String colorInvert = '';

    if (hex != null) {
      colorInvert = invertHex('#$hex');
    }

    if (word != null) {
      colorInvert = invertWord(word);
    }

    return 'color: ' + colorInvert;
  }

  static String invertRgb(String rgb) {
    RegExp regex = RegExp(r'rgba?\(\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,\s*(\d{1,3})\s*(?:,\s*([01](?:\.\d*)?)\s*)?\)');

    if (!regex.hasMatch(rgb)) {
      return _invertRgbaVar(rgb);
    }

    RegExpMatch match = regex.firstMatch(rgb)!;

    String r = match.group(1)!;
    String g = match.group(2)!;
    String b = match.group(3)!;
    String? a = match.group(4);

    if (int.parse(r) < 0 || int.parse(r) > 255 || int.parse(g) < 0 || int.parse(g) > 255 || int.parse(b) < 0 || int.parse(b) > 255) {
      return '';
    }

    String rInvert = (255 - int.parse(r)).toString();
    String gInvert = (255 - int.parse(g)).toString();
    String bInvert = (255 - int.parse(b)).toString();

    String rgbInvert = 'rgb(' + rInvert + ',' + gInvert + ',' + bInvert + ')';
    if (a != null) {
      rgbInvert = 'rgba(' + rInvert + ',' + gInvert + ',' + bInvert + ',' + a + ')';
    }

    return 'color: ' + rgbInvert;
  }

  static String _invertRgbaVar(String str) {
    RegExp regex = RegExp(r'color:\s*rgba\(\s*(\d+|\w+)\s*,\s*(\d+|\w+)\s*,\s*(\d+|\w+)\s*,\s*(.*)\s*\)');

    // 判断输入的字符串是否符合正则表达式，如果不符合，返回空字符串
    if (!regex.hasMatch(str)) {
      return '';
    }

    // 获取正则表达式在输入字符串中的第一个匹配
    RegExpMatch? match = regex.firstMatch(str);
    if (match == null) {
      return '';
    }

    // 获取匹配到的四个颜色值，比如229,231,235,var(--tw-border-opacity)
    String r = match.group(1)!;
    String g = match.group(2)!;
    String b = match.group(3)!;
    String a = match.group(4)!;

    String rgbInvert = '';

    if (int.tryParse(r) != null &&
        int.tryParse(g) != null &&
        int.tryParse(b) != null &&
        int.parse(r) >= 0 &&
        int.parse(r) <= 255 &&
        int.parse(g) >= 0 &&
        int.parse(g) <= 255 &&
        int.parse(b) >= 0 &&
        int.parse(b) <= 255) {
      rgbInvert = (255 - int.parse(r)).toString() + ',' + (255 - int.parse(g)).toString() + ',' + (255 - int.parse(b)).toString();
    } else {
      rgbInvert = r + ',' + g + ',' + b;
    }

    String result = 'color: rgba(' + rgbInvert + ',' + a + ')';

    return result;
  }

  static String invertHex(String hex) {
    var hexColor2 = hexColor(hex, argb: false);
    var red = 255 - hexColor2.red;
    var green = 255 - hexColor2.green;
    var blue = 255 - hexColor2.blue;
    var result = Color.fromRGBO(red, green, blue, hexColor2.opacity);
    return colorToCss(result);
  }

// 定义一个函数，接受一个英文单词颜色值作为参数，返回一个反色的英文单词颜色值
  static String invertWord(String word) {
    switch (word.toLowerCase()) {
      case 'white':
        return 'black';
      case 'black':
        return 'white';
      default:
        return word;
    }
  }

  static bool isColorString(String colorString) {
    if (TextUtil.isEmpty(colorString)) {
      return false;
    }
    if (!colorString.startsWith('0x') && !colorString.startsWith('#')) {
      LogUtil.e('wrong color hexvalue: $colorString', tag: 'color parse');
      return false;
    }
    if (colorString.startsWith('0x')) {
      colorString = colorString.substring(2);
    } else {
      colorString = colorString.substring(1);
    }
    for (int i = 0; i < colorString.length; i++) {
      var char = colorString[i].toLowerCase();
      if (!colorValueAlphabet.contains(char)) {
        LogUtil.e('wrong color hexvalue: $colorString', tag: 'color parse');
        return false;
      }
    }
    return true;
  }

  ///
  /// argb is false => rgba
  static Color hexColor(String colorString, {bool argb = true}) {
    if (TextUtil.isEmpty(colorString)) {
      return Colors.transparent;
    }
    String alphaStr;
    String redStr;
    String greenStr;
    String blueStr;
    if (!colorString.startsWith('0x') && !colorString.startsWith('#')) {
      LogUtil.e('wrong color hexvalue: $colorString', tag: 'color parse');
      return Colors.transparent;
    }
    if (colorString.startsWith('0x')) {
      colorString = colorString.substring(2);
    } else {
      colorString = colorString.substring(1);
    }
    for (int i = 0; i < colorString.length; i++) {
      var char = colorString[i].toLowerCase();
      if (!colorValueAlphabet.contains(char)) {
        LogUtil.e('wrong color hexvalue: $colorString', tag: 'color parse');
        return Colors.transparent;
      }
    }
    switch (colorString.length) {
      case 3: // case #aaa, transform to #ffaaaaaa
        alphaStr = 'ff';
        redStr = '${colorString[0]}${colorString[0]}';
        greenStr = '${colorString[1]}${colorString[1]}';
        blueStr = '${colorString[2]}${colorString[2]}';
        break;
      case 4: // case #argb, transform to #aarrggbb, case #rgba transform to #aarrggbb
        if (argb) {
          alphaStr = '${colorString[0]}${colorString[0]}';
          redStr = '${colorString[1]}${colorString[1]}';
          greenStr = '${colorString[2]}${colorString[2]}';
          blueStr = '${colorString[3]}${colorString[3]}';
        } else {
          redStr = '${colorString[0]}${colorString[0]}';
          greenStr = '${colorString[1]}${colorString[1]}';
          blueStr = '${colorString[2]}${colorString[2]}';
          alphaStr = '${colorString[3]}${colorString[3]}';
        }
        break;
      case 6: // case #aaaaaa, transform to #ffaaaaaa
        alphaStr = 'ff';
        redStr = '${colorString[0]}${colorString[1]}';
        greenStr = '${colorString[2]}${colorString[3]}';
        blueStr = '${colorString[4]}${colorString[5]}';
        break;
      case 8: // case #ffaaaaaa
        if (argb) {
          alphaStr = '${colorString[0]}${colorString[1]}';
          redStr = '${colorString[2]}${colorString[3]}';
          greenStr = '${colorString[4]}${colorString[5]}';
          blueStr = '${colorString[6]}${colorString[7]}';
        } else {
          redStr = '${colorString[0]}${colorString[1]}';
          greenStr = '${colorString[2]}${colorString[3]}';
          blueStr = '${colorString[4]}${colorString[5]}';
          alphaStr = '${colorString[6]}${colorString[7]}';
        }
        break;
      default:
        LogUtil.e('wrong color hexvalue: $colorString', tag: 'color parse');
        return Colors.transparent;
    }
    Color color = Color(int.parse('0x$alphaStr$redStr$greenStr$blueStr'));
    return color;
  }

  static String colorToCss(Color color) {
    return 'rgba(${color.red},${color.green},${color.blue},${color.opacity})';
  }
}

extension ColorEx on Color {
  String hexValue({bool leadingHashSign = true}) {
    return '${leadingHashSign ? '#' : ''}'
        '${alpha.toRadixString(16).padLeft(2, '0').toUpperCase()}'
        '${red.toRadixString(16).padLeft(2, '0').toUpperCase()}'
        '${green.toRadixString(16).padLeft(2, '0').toUpperCase()}'
        '${blue.toRadixString(16).padLeft(2, '0').toUpperCase()}';
  }

  Color toArgb() {
    int abgrValue = (this.alpha << 24) | (this.blue << 16) | (this.green << 8) | this.red;
    return Color(abgrValue);
  }
}
