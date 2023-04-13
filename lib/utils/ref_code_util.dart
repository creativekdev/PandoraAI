class RefCodeUtils {
  static String? pickRefCode(String? source) {
    if (source == null) return null;
    var regExp = RegExp(r'^(https:\/\/(socialbook\.io|allsha\.re\/a\/pandoraai)|pai:\/\/pandora\.ai).*?rf=.*$');
    if (!regExp.hasMatch(source)) {
      return null;
    }
    var urls = source.split('?');
    var params = urls[1].split('&');
    for (var value in params) {
      if (value.startsWith('rf=')) {
        var code = value.replaceAll('rf=', '');
        return code;
      }
    }
    return null;
  }
}
