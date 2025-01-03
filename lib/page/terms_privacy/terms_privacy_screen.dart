import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/main.dart';
import 'package:holdem/widget/common_app_bar.dart';

part 'terms_privacy_controller.dart';

class TermsPrivacyPage extends StatelessWidget {
  const TermsPrivacyPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TermsPrivacyController>(
      init: TermsPrivacyController(),
      builder: (controller) {
        return Scaffold(
          appBar: CommonAppBar.arrowBack(
            context,
            title: controller.title,
          ),
          body: controller.url.isNotEmpty
              ? Stack(
                  children: [
                    InAppWebView(
                      initialUrlRequest: URLRequest(
                        url: WebUri(controller.url),
                      ),
                      initialSettings: InAppWebViewSettings(
                        supportZoom: false,
                        useHybridComposition : false,
                      ),
                      onLoadStart: (controller, url) {
                        controller.injectCSSCode(source: ':root {touch-action: pan-x pan-y;height: 100%}');
                      },
                      onLoadStop: (controller, url) {
                        controller.injectCSSCode(source: ':root {touch-action: pan-x pan-y;height: 100%}');
                      },
                      onProgressChanged: (_, progress) {
                        if (progress / 100 > 0.999) {
                          controller.onLoadStop();
                        }
                      },
                      // onTitleChanged: (_, title) {
                      //   controller.onWebTitleChanged(title ?? '');
                      // },
                    ),
                    if (controller.isLoading)
                      const ColoredBox(
                        color: Colors.white,
                        child: Center(child: CupertinoActivityIndicator()),
                      )
                    else
                      const SizedBox(),
                  ],
                )
              : SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.w),
                  child: Text(
                    '''
德学院用户协议

更新日期：2025年1月

欢迎您使用德学院（以下简称“本应用”）！在使用本应用之前，请您务必仔细阅读并充分理解本《用户协议》（以下简称“本协议”）。您的注册、登录、使用行为将视为您对本协议的接受，并同意受其约束。

如您为未满18岁的未成年人，请在监护人指导下阅读本协议并明确您的权利和义务。

一、协议范围

1. 本协议是用户与德学院之间关于使用本应用相关服务的法律协议。
2. 本协议适用于本应用提供的各项服务，包括但不限于教学内容、论坛互动、赛事资讯等功能。

二、用户注册与账户管理

1. 用户资格
• 您须年满18周岁方可注册使用本应用。
• 若发现用户提供虚假信息或违反法律法规的行为，德学院有权随时终止服务。
2. 账户安全
• 用户应妥善保管账户信息，确保账户安全。
• 如账户出现异常登录或被盗用，应立即通知德学院。

三、服务使用规则

1. 合法使用
• 您承诺在使用本应用过程中遵守所有适用法律法规，不发布违法、侵权、侮辱性或其他不适当内容。
• 禁止利用本应用进行任何形式的赌博、欺诈或违法活动。
2. 用户行为
• 用户应对其在本应用中发布的内容（如评论、帖子）承担全部责任。
• 禁止发布广告、垃圾信息或扰乱社区秩序的内容。
3. 内容限制
• 本应用内教学、资讯等内容仅供学习和娱乐用途，不得用于商业目的。
• 用户未经授权不得擅自复制、修改、传播或公开展示本应用内容。

四、隐私与数据保护

1. 数据收集
• 本应用将按照相关法律规定收集和使用用户的必要信息，具体详见《隐私政策》。
2. 信息安全
• 本应用采取合理措施保护用户数据的安全，但无法保证信息绝对安全。用户需自行承担因不可抗力或第三方非法行为导致的信息泄露风险。

五、知识产权声明

1. 本应用内的所有内容（包括但不限于文字、图片、视频、代码）均受著作权、商标权等相关法律保护，未经授权不得使用。
2. 用户在本应用发布的原创内容，其著作权归用户所有，但用户同意德学院在全球范围内无偿使用其发布的内容。

六、服务变更与终止

1. 本应用保留在任何时间内修改、更新或停止部分或全部服务的权利。
2. 用户在任何时候均可注销账户，注销后本应用将停止为用户提供服务，并按法律要求删除相关数据。

七、免责声明

1. 本应用不对因用户操作不当或第三方行为导致的任何损失承担责任。
2. 对于不可抗力导致的服务中断或数据损失，本应用免责。

八、违约处理

1. 若用户违反本协议条款，本应用有权采取以下措施：
• 删除用户发布的违规内容；
• 暂停或终止用户使用服务；
• 追究用户法律责任。

九、协议修改与通知

1. 本应用有权根据业务需要或法律变化修改本协议。修改后的协议将在本应用内或官方网站公告，修改内容即时生效。
2. 用户继续使用本应用服务即视为接受修订后的协议。

十、其他

1. 本协议的成立、履行、解释及争议解决均适用新加坡法律。
2. 若本协议部分条款因任何原因被判定为无效或不可执行，其余条款仍然有效。

十一、联系我们

如您对本协议有任何疑问，可通过以下方式与我们联系：
• 电子邮件：support@dpoker.club
• 公司地址：10 Anson Road, International Plaza, Singapore 079903

感谢您选择德学院！祝您使用愉快！
''',
                    style: TextStyle(
                      color: const Color(0xff2a2a2a),
                      fontSize: 12.sp,
                    ),
                  ),
                ),
        );
      },
    );
  }
}
