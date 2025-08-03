import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:holdem/services/points_service.dart';
import 'package:holdem/utils/dialog_util.dart';

class PointsConversionController extends GetxController with GetSingleTickerProviderStateMixin{
  late AnimationController animationController;
  late Animation<double> animation;
  final TextEditingController textEditingController = TextEditingController();
  var pointsData = {}.obs;
  RxInt coinAutoTransStatus = 1.obs;
  RxString dxyBalance = '0.00'.obs;
  RxString dpkBalance = '0.00'.obs;
  RxBool canTap = false.obs;
  RxString tips = ''.obs;
  RxBool isPointToCoin = true.obs;

  @override
  void onReady() {
    super.onReady();
    _requestData();
    animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    // 创建角度动画（0 ~ 360度 → 0.0 ~ 2π弧度）
    animation = Tween<double>(begin: 0, end: 2 * 3.14159265359).animate(animationController)
      ..addListener(() {

      });
  }

  @override
  void onClose() {
    animationController.dispose();
    textEditingController.dispose();
    super.onClose();
  }

  // TODO: Private Method

  void _requestData() async {
    final data =  await PointsService.coinBalance();
    if (data != null) {
      pointsData.value = data;
      coinAutoTransStatus.value = data['coinAutoTransStatus'] ?? 0;
      dxyBalance.value = '${data['dxyBalance'] ?? 0.00}';
      dpkBalance.value = '${data['dpkBalance'] ?? 0.00}';
    }
  }

  void _coinAutoTransStatus(value) async {
    int status = value == true ? 1 : 0;
    final res = await PointsService.coinAutoTransStatus({'status': status});
    if (res?.isSuccess) {
      coinAutoTransStatus.value = value == true ? 1 : 0;
    }
  }

  // TODO: Public Method

  void onChanged(value) {
    _coinAutoTransStatus(value);
  }

  void textOnChanged(text) {
    tips.value = '';
    canTap.value = textEditingController.text.isNotEmpty ? true : false;
    if (text.isNotEmpty) {
      if (isPointToCoin.value) {
        if (double.tryParse(text)! > double.tryParse(dxyBalance.value)! ||
            double.tryParse(dxyBalance.value) == 0.00) {
          canTap.value = false;
          tips.value = '积分不足';
        }
      } else {
        if (double.tryParse(text)! > double.tryParse(dpkBalance.value)! ||
            double.tryParse(dpkBalance.value) == 0.00) {
          canTap.value = false;
          tips.value = '请输入有效转换额度';
        }
      }
    }
  }

  void allOnTap() {
    if (isPointToCoin.value) {
      textEditingController.text = '${int.tryParse(dxyBalance.value) ?? 0}';
    } else {
      textEditingController.text = '${int.tryParse(dpkBalance.value) ?? 0}';
    }
    textOnChanged(textEditingController.text);
  }

  void sureOnTap() async {
    if (textEditingController.text.isEmpty) {
      String str = isPointToCoin.value ? '积分' : '金币';
      DialogUtil.showToast('请输入$str');
      return;
    }
    final res = await PointsService.coinTrans({
      'transType': isPointToCoin.value ? 1 : 2,
      'amount': textEditingController.text
    });
    if (res?.isSuccess) {
      canTap.value = false;
      textEditingController.text = '';
      DialogUtil.showToast('转换成功');
      _requestData();
    } else {
      DialogUtil.showToast('${res?.msg}');
    }
  }

  void changeOnTap() {
    tips.value = '';
    textEditingController.text = '';
    isPointToCoin.value = !isPointToCoin.value;
    animationController.forward();
  }
}
