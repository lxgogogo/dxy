part of flutter_telegram_login;
String extractAcceptUrl(String html) {
  int confirmUrlIndex = html.indexOf('confirm_url');
  if (confirmUrlIndex != -1) {
    String substringAfterConfirmUrl = html.substring(confirmUrlIndex);
    int urlEndIndex = substringAfterConfirmUrl.indexOf(RegExp(r'[,]'));
    if (urlEndIndex != -1) {
      String confirmUrlValue =
          substringAfterConfirmUrl.substring(0, urlEndIndex).replaceAll(' ', '');
      return confirmUrlValue.replaceAll('confirm_url=', '').replaceAll('\'', '');
    }
  }
  return '';
}


