part of flutter_telegram_login;

class TelegramLogin {
  static TelegramLogin? _instance;
  static TelegramLogin get instance {
    _instance = _instance ?? TelegramLogin();
    return _instance!;
  }

  final _baseUrl = 'https://oauth.telegram.org';
  final Session _session = Session();
  late String _phoneNumber;
  late String _botId;
  late String _botDomain;
  late String _acceptUrl = '';

  TelegramLogin();

  Future<Map<String, String>?> loginTelegram({
    required String phone,
    required String botId,
    required String domain,
  }) async {
    _phoneNumber = phone.replaceAll(RegExp('\\+'), '').replaceAll(RegExp(' '), '');
    _botId = botId;
    _botDomain = domain;

    final request = await _requestLogin();
    if (request) {
      await _telegramLaunch();
      final confirm = await _checkLoginAcceptTimeOut();
      if (!confirm) {
        return null;
      }
      Map<String, String>? info = await _getData();
      if (info == null) {
        await _acceptRequest();
        info = await _getData();
      }
      return info;
    }
    return {};
  }

  Future<bool> _requestLogin() async {
    Map<String, String> headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'origin': _botDomain,
    };
    final ans = await _session.post(
      '$_baseUrl/auth/request?bot_id=$_botId&origin=$_botDomain&embed=1',
      headers,
      'phone=$_phoneNumber',
    );

    return ans == 'true';
  }

  Future<bool> _checkConfirm() async {
    Map<String, String> headers = {
      'Content-length': '0',
      'Content-Type': 'application/x-www-form-urlencoded',
      'origin': _botDomain,
    };
    final ans = await _session.post(
        '$_baseUrl/auth/login?bot_id=$_botId&origin=$_botDomain&embed=1', headers, '');
    return ans == 'true';
  }

  Future<Map<String, String>?> _getData() async {
    final ans = await _session.get('$_baseUrl/auth?bot_id=$_botId&origin=$_botDomain&embed=1', {
      'Accept': 'application/json',
      'Content-Type': 'application/x-www-form-urlencoded',
      'origin': _botDomain,
    });
    try {
      String id = ans.split('"id":')[1].split(',')[0];
      String firstName = ans.split('"first_name":"')[1].split('",')[0];
      String photoUrl = ans.split('"photo_url":"')[1].split('"')[0];
      String username = firstName;
      String lastName = '';
      if (ans.contains('last_name')) {
        lastName = ans.split('"last_name":"')[1].split('",')[0];
        username = '$firstName $lastName';
      }
      if (ans.contains('username')) {
        username = ans.split('"username":"')[1].split('",')[0];
      }

      return {
        'id': id,
        'first_name': firstName,
        'last_name': lastName,
        'user_name': username,
        'photo_url': photoUrl.replaceAll('\\/', '/'),
        'phone': _phoneNumber,
      };
    } catch (e) {
      _acceptUrl = extractAcceptUrl(ans);
      return null;
    }
  }

  Future<bool> _checkLoginAcceptTimeOut() async {
    int interval = 1;
    const int transactionTimeOut = 15;
    while (interval <= transactionTimeOut) {
      await Future.delayed(const Duration(seconds: 1));
      if (await _checkConfirm()) {
        return true;
      }
      interval++;
    }
    return false;
  }

  Future<void> _telegramLaunch() async {
    if (!await launchUrl(
      Uri.parse('https://t.me/+42777'),
      mode: LaunchMode.externalApplication,
    )) {
      throw 'Could not launch Telegram';
    }
  }

  Future<void> _acceptRequest() async {
    Map<String, String> headers = {
      'Content-length': '0',
      'Content-Type': 'application/x-www-form-urlencoded',
      'origin': _botDomain,
    };
    await _session.post('$_baseUrl$_acceptUrl', headers, '');
  }
}
