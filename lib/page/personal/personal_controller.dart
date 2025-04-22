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
        ToastUtils.showToast('上传头像不得超过10M');
        return;
      }
      if (picked.path.isNotEmpty) {
        await NetRequest().updateAvatar(picked.path, (data) {
          imageUrl = picked.path;
          ToastUtils.showToast('上传成功');
          final url = data?['url'];
          if (url is String) {
            UserStore.of.updateUserInfo({'avatar': url});
          }
        }, (errMsg) {
          ToastUtils.showToast('上传文件失败，请重新上传');
        }, (int sent, int total) {}).whenComplete(() {
          safeUpdate();
        });
      }
    }
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      if (isAuthorizing) return;
      isAuthorizing = true;
      final googleUser = await GoogleSignIn().signIn();
      EasyLoading.show(status: 'loading...');
      final googleAuth = await googleUser?.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final idTokenResult = await userCredential.user?.getIdTokenResult(true);
      final res = await LoginService.of.bindThirdLogin(
        type: 'GOOGLE',
        token: idTokenResult?.token ?? '',
      );
      EasyLoading.dismiss();
      if (res.isSuccess) {
        ToastUtils.showToast('绑定成功');
        final userProfile = UserProfile.fromJson(res.data['user']);
        UserStore.of.putUserInfo(userProfile);
        // TrackUtils.trackEvent(userLogType: '115005', params: '谷歌');
      } else {
        ToastUtils.showToast(res.msg);
        // if (!context.mounted) return;
        // showDialog(
        //   context: context,
        //   builder: (context) => DialogNewTip(
        //     title: '绑定失败',
        //     content: res.msg,
        //   ),
        // );
      }
    } finally {
      isAuthorizing = false;
    }
  }

  Future<void> signInWithApple(BuildContext context) async {
    // final credential = await SignInWithApple.getAppleIDCredential(
    //   scopes: [
    //     AppleIDAuthorizationScopes.email,
    //     AppleIDAuthorizationScopes.fullName,
    //   ],
    // );
    // EasyLoading.show(status: 'loading...');
    try {
      if (isAuthorizing) return;
      isAuthorizing = true;
      final appleProvider = AppleAuthProvider()
        ..addScope('email')
        ..addScope('name');
      final auth = await FirebaseAuth.instance.signInWithProvider(appleProvider);
      EasyLoading.show(status: 'loading...');
      final idTokenResult = await auth.user?.getIdTokenResult(true);
      final res = await LoginService.of.bindThirdLogin(
        type: 'APPLE',
        token: idTokenResult?.token ?? '',
      );
      // final res = await LoginService.of.thirdLogin(
      //   type: 'APPLE',
      //   token: credential.identityToken ?? '',
      // );
      EasyLoading.dismiss();
      if (res.isSuccess) {
        ToastUtils.showToast('绑定成功');
        final userProfile = UserProfile.fromJson(res.data['user']);
        UserStore.of.putUserInfo(userProfile);
        // TrackUtils.trackEvent(userLogType: '115005', params: '苹果');
      } else {
        ToastUtils.showToast(res.msg);
        // if (!context.mounted) return;
        // showDialog(
        //   context: context,
        //   builder: (context) => DialogNewTip(
        //     title: '绑定失败',
        //     content: res.msg,
        //   ),
        // );
      }
    } finally {
      isAuthorizing = false;
    }
  }

  Future<void> signInWithTelegram(BuildContext context) async {
    final token = await Get.toNamed(Routes.telegramLogin);
    if (token is String) {
      final res = await LoginService.of.bindThirdLogin(
        type: 'TELEGRAM',
        token: token,
      );
      EasyLoading.dismiss();
      if (res.isSuccess) {
        ToastUtils.showToast('绑定成功');
        final userProfile = UserProfile.fromJson(res.data['user']);
        UserStore.of.putUserInfo(userProfile);
        // TrackUtils.trackEvent(userLogType: '115005', params: 'TG');
      } else {
        ToastUtils.showToast(res.msg);
        // if (!context.mounted) return;
        // showDialog(
        //   context: context,
        //   builder: (context) => DialogNewTip(
        //     title: '绑定失败',
        //     content: res.msg,
        //   ),
        // );
      }
    }
  }
}
