import 'dart:convert';
import 'package:crypto/crypto.dart' as crypto;
import 'package:crypto/crypto.dart';


String sToken(Map<String, dynamic> params) {
  var keys = params.keys.toList();
  keys.sort();

  var str = "x";
  for (var i = 0; i < keys.length; i++) {
    str += keys[i] + params[keys[i]];
  }
  var content = new Utf8Encoder().convert('socialbook');
  var md5 = crypto.md5;
  var digest = md5.convert(content);
  str += digest.toString();
  var bytes1 = utf8.encode(str);
  var digest1 = sha256.convert(bytes1);
  var finalValue = digest1.toString().substring(3, 3 + 17);

  return finalValue;
}
