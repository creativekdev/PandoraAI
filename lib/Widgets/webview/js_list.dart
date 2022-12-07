
import 'dart:convert';

class JsList {
  static String postToWebView(String message, Map<String, dynamic> value) {
    return 'window.postMessage(\'$message\', \'${json.encode(value)}\');';
  }
}