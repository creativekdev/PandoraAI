import 'dart:convert';
import 'package:crypto/crypto.dart' as crypto;
import 'package:crypto/crypto.dart';

String sToken(Map<String, dynamic> params) {
  var str = "x" + appendMapParams(params);
  var content = new Utf8Encoder().convert('socialbook');
  var md5 = crypto.md5;
  var digest = md5.convert(content);
  str += digest.toString();
  var bytes1 = utf8.encode(str);
  var digest1 = sha256.convert(bytes1);
  var finalValue = digest1.toString().substring(3, 3 + 17);
  return finalValue;
}

String appendMapParams(Map<String, dynamic> params) {
  String str = '';
  var keys = params.keys.toList();
  keys.sort();
  for (var key in keys) {
    var value = params[key];
    if (value is List) {
      str += key + appendArrayParams(value);
    } else if (value is Map<String, dynamic>) {
      str += key + appendMapParams(value);
    } else {
      str += key + value.toString();
    }
  }
  return str;
}

String appendArrayParams(List<dynamic> params) {
  String temp = '';
  params.forEach((element) {
    if (element is List) {
      temp += appendArrayParams(element) + ',';
    } else if (element is Map<String, dynamic>) {
      temp += appendMapParams(element) + ',';
    } else {
      temp += element.toString() + ',';
    }
  });
  if (temp.endsWith(',')) {
    temp = temp.substring(0, temp.length - 1);
  }
  return temp;
}
