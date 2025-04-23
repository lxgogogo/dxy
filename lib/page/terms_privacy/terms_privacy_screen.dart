import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/string_extensions.dart';
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
          backgroundColor: '#F7F8FC'.hexColor,
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
欢迎您注册并使用“德学院”应用（以下简称“本平台”）。在使用我们的服务前，请您仔细阅读并充分理解本协议。您点击“同意”即视为您已阅读、理解并接受本协议的全部内容，并愿意受其约束。

一、服务内容
 1. 本平台是一个面向德州扑克爱好者的教学与互动交流平台，旨在为用户提供德州扑克相关的内容资讯、学习资源、社区互动、赛事动态等服务。
 2. 所有内容仅用于教学与交流目的，不提供、不涉及任何形式的线上或线下博彩服务或工具。

二、用户注册与账号管理
 1. 用户在注册时应提供真实、准确、合法的个人信息，并妥善保管账号与密码，防止账号被盗用或滥用。
 2. 用户不得使用他人信息注册账号，亦不得通过任何技术手段恶意注册、滥用平台资源。
 3. 若发现用户有违规使用行为，平台有权视情节严重程度暂停或终止服务。

三、用户行为规范
 1. 用户在平台内的所有发言、评论、上传的内容必须遵守以下规则：
 • 不得发布任何违反所在地法律法规的信息；
 • 不得发布淫秽、暴力、诈骗、侵权、虚假广告等内容；
 • 不得发布、传播与博彩、私彩相关的内容链接或引流信息；
 • 尊重他人，禁止人身攻击、辱骂或骚扰行为。
 2. 对于违反以上规定的用户，平台有权删除其内容、限制功能使用或终止账号。

四、内容权属与知识产权
 1. 平台内所有原创内容归平台或原作者所有，未经授权不得擅自转载、复制或用于商业用途。
 2. 用户上传或发布的内容应不侵犯任何第三方的合法权益，如有争议，责任由用户自行承担。

五、隐私与数据保护
 1. 平台将依法保护用户隐私，用户的注册信息及使用数据仅用于提供服务及优化体验，不会向第三方出售或非法分享。
 2. 仅在以下情况可能披露用户信息：
 • 经用户本人授权；
 • 遵守法律法规的要求；
 • 保障平台或他人合法权益。

六、免责声明
 1. 本平台提供的信息仅供参考，用户需自行判断和承担使用结果的风险。
 2. 平台不对因网络故障、第三方攻击或不可抗力造成的服务中断承担赔偿责任。

七、适用法律与争议解决
 1. 本协议受服务所在地法律管辖（若无特别约定，则默认适用国际通行互联网规范及新加坡法律）。
 2. 若发生争议，用户与平台应协商解决；协商不成的，提交平台服务所在地有管辖权的法院处理。

八、协议的修改与解释权
 1. 本协议内容如有更新，平台将通过适当方式予以公示，用户有权选择是否继续使用。
 2. 本协议最终解释权归“德学院”平台所有。
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
