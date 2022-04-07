import 'dart:convert';
import 'package:crypto/crypto.dart' as crypto;
import 'package:cartoonizer/Model/JsonValueModel.dart';
import 'package:crypto/crypto.dart';

String sToken(List<JsonValueModel> params){
  params.sort();
  var str = "x";
  for(var i = 0; i < params.length; i++){
    str += params[i].key + params[i].value;
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