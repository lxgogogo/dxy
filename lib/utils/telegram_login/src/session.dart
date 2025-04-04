part of flutter_telegram_login;

class Session {
  String cookies = '';
  Session();

  Future<String> get(String url, Map<String, String> headers) async {
    var uri = Uri.parse(url);
    headers['cookie'] = cookies;
    final response = await http.get(uri, headers: headers);
    if (response.headers['set-cookie'] != null) {
      cookies = '$cookies${response.headers["set-cookie"]!};';
    }
    return response.body;
  }

  String addCookiesFromCookiesInfo(String cookies, List<String> cookiesInfo) {
    for (String s in cookiesInfo) {
      if (s.split('=').length < 2) {
        continue;
      }
      var name = s.split('=')[0];
      if (!(name.contains('path')) &&
          !(name.contains('samesite')) &&
          !(name.contains('secure')) &&
          !(name.contains('expires'))) {
        s = s.replaceAll('HttpOnly,', '');
        cookies = '$cookies$s;';
      }
    }
    return cookies;
  }

  Future<String> post(String url, Map<String, String> headers, String body) async {
    var uri = Uri.parse(url);
    headers['cookie'] = cookies;
    final response = await http.post(uri, headers: headers, body: body);
    var cookiesInfo = response.headers['set-cookie']?.split(';');
    if (cookiesInfo != null) {
      cookies = addCookiesFromCookiesInfo(cookies, cookiesInfo);
    }
    return response.body;
  }
}
