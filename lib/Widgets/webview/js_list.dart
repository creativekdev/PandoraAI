import 'dart:convert';

class JsList {
  static String postToWebView(String message, Map<String, dynamic> value) {
    return 'window.postMessage(\'$message\', \'${json.encode(value)}\');';
  }

  static String getSizeChangedJavascript() {
    return 'onSizeChanged.postMessage('
        'JSON.stringify({width: document.body.scrollWidth,'
        'height: document.body.scrollHeight,}));';
  }

  static String getImgWidthResizeJavascript({double percent = 90}) {
    return 'var images = document.images;'
        'for (var i=0; i < images.length; i++) {'
        '     var image = images[i];'
        '     if (image.width > document.body.scrollWidth * $percent / 100) {'
        '          image.style.width = "$percent%";'
        '     }'
        '}';
  }
}
