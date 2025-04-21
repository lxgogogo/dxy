class CaptchaResultModel {
  String? passToken;
  int? genTime;
  String? captchaOutput;
  String? captchaId;
  String? lotNumber;

  CaptchaResultModel({
    this.passToken,
    this.genTime,
    this.captchaOutput,
    this.captchaId,
    this.lotNumber,
  });

  factory CaptchaResultModel.fromJson(Map<String, dynamic> json) => CaptchaResultModel(
        passToken: json["pass_token"],
        genTime: json["gen_time"],
        captchaOutput: json["captcha_output"],
        captchaId: json["captcha_id"],
        lotNumber: json["lot_number"],
      );

  Map<String, dynamic> toJson() => {
        "pass_token": passToken,
        "gen_time": genTime,
        "captcha_output": captchaOutput,
        "captcha_id": captchaId,
        "lot_number": lotNumber,
      };
}
