part of 'personal_screen.dart';

class PersonalScreenController extends GetxController {
  String imageUrl = ""; //本地图片地址

  bool isAuthorizing = false;

  @override
  void onReady() {
    UserStore.of.getUserInfo();
    super.onReady();
  }

  selectImage() async {
    final ImagePicker picker = ImagePicker();
    var picked = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (picked != null) {
      final fileLength = await picked.length();
      if (fileLength > 10 * 1024 * 1024) {
        DialogUtil.showToast('上传头像不得超过10M');
        return;
      }
      if (picked.path.isNotEmpty) {
        await NetRequest().updateAvatar(picked.path, (data) {
          imageUrl = picked.path;
          DialogUtil.showToast('上传成功');
          final url = data?['url'];
          if (url is String) {
            UserStore.of.updateUserInfo({'avatar': url});
          }
        }, (errMsg) {
          DialogUtil.showToast('上传文件失败，请重新上传');
        }, (int sent, int total) {}).whenComplete(() {
          safeUpdate();
        });
      }
    }
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    if (Env.isAndroidAAb) {
      await thirdWebLogin('GOOGLE', Env.googleLogin);
      return;
    }
    try {
      if (isAuthorizing) return;
      isAuthorizing = true;
      final googleUser = await GoogleSignIn().signIn();
      DialogUtil.showLoading();
      final googleAuth = await googleUser?.authentication;
      if (googleAuth == null) return;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final idTokenResult = await userCredential.user?.getIdTokenResult(true);
      final res = await LoginService.of.bindThirdLogin(
        type: 'GOOGLE',
        token: idTokenResult?.token ?? '',
      );
      if (res.isSuccess) {
        DialogUtil.showToast('绑定成功');
        final userProfile = UserProfile.fromJson(res.data);
        UserStore.of.putUserInfo(userProfile);
      } else {
        DialogUtil.showToast(res.msg);
      }
    } finally {
      DialogUtil.dismiss();
      isAuthorizing = false;
    }
  }

  Future<void> signInWithApple(BuildContext context) async {
    if (Env.isAndroidAAb) {
      await thirdWebLogin('APPLE', Env.appleLogin);
      return;
    }
    try {
      if (isAuthorizing) return;
      isAuthorizing = true;
      final appleProvider = AppleAuthProvider()
        ..addScope('email')
        ..addScope('name');
      final auth = await FirebaseAuth.instance.signInWithProvider(appleProvider);
      DialogUtil.showLoading();
      final idTokenResult = await auth.user?.getIdTokenResult(true);
      final res = await LoginService.of.bindThirdLogin(
        type: 'APPLE',
        token: idTokenResult?.token ?? '',
      );
      if (res.isSuccess) {
        DialogUtil.showToast('绑定成功');
        final userProfile = UserProfile.fromJson(res.data);
        UserStore.of.putUserInfo(userProfile);
      } else {
        DialogUtil.showToast(res.msg);
      }
    } finally {
      DialogUtil.dismiss();
      isAuthorizing = false;
    }
  }

  Future<void> signInWithTelegram(BuildContext context) async {
    try {
      if (isAuthorizing) return;
      isAuthorizing = true;
      final token = await Get.toNamed(
        Routes.webLogin,
        arguments: {'type': 'TELEGRAM', 'authUrl': Env.telegramLogin},
      )?.whenComplete(() {
        DialogUtil.dismiss();
      });
      ;
      if (token is String) {
        DialogUtil.showLoading();
        final res = await LoginService.of.bindThirdLogin(
          type: 'TELEGRAM',
          token: token,
        );
        DialogUtil.dismiss();
        if (res.isSuccess) {
          DialogUtil.showToast('绑定成功');
          final userProfile = UserProfile.fromJson(res.data);
          UserStore.of.putUserInfo(userProfile);
        } else {
          DialogUtil.showToast(res.msg);
        }
      }
    } finally {
      DialogUtil.dismiss();
      isAuthorizing = false;
    }
  }

  Future<void> thirdWebLogin(
    String type,
    String url,
  ) async {
    if (isAuthorizing) return;
    isAuthorizing = true;
    try {
      final token = await Get.toNamed(
        Routes.webLogin,
        arguments: {'type': type, 'authUrl': url},
      )?.whenComplete(() {
        DialogUtil.dismiss();
      });
      if (token is String) {
        DialogUtil.showLoading();
        final res = await LoginService.of.bindThirdLogin(
          type: type,
          token: token,
          isOrigin: true,
        );
        if (res.isSuccess) {
          DialogUtil.showToast('绑定成功');
          final userProfile = UserProfile.fromJson(res.data);
          UserStore.of.putUserInfo(userProfile);
        } else {
          DialogUtil.showToast(res.msg);
        }
      }
    } catch (e) {
      DialogUtil.showToast(e.toString());
    } finally {
      DialogUtil.dismiss();
      isAuthorizing = false;
    }
  }

  void loginOut(context) {
    Get.toNamed(Routes.deleteAccount);
  }
}
