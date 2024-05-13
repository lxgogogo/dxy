import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:holdem/page/mine/login_helper.dart';
import 'package:holdem/utils/size_fit.dart';

///
/// 左侧圆形头像，右侧顶部text，右侧底部2个text
///
class CircleImageWithText extends StatelessWidget {
  final String imageUrl;
  final double imageWidth;
  final double imageHeight;
  final String topText;
  final TextStyle topTextStyle;
  final String bottomText1;
  final String bottomText2;
  final TextStyle bottomText1Style;
  final TextStyle bottomText2Style;

  CircleImageWithText({
    required this.imageUrl,
    required this.imageWidth,
    required this.imageHeight,
    required this.topText,
    required this.topTextStyle,
    required this.bottomText1,
    required this.bottomText2,
    required this.bottomText1Style,
    required this.bottomText2Style,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
          child: ClipOval(
              child: LoginHelper()
                  .getUserAvatar(imageUrl, imageWidth, imageHeight)),
        ),
        Container(
          height: imageHeight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopText(),
              Expanded(child: _buildBottomText()),
            ],
          ),
        )
      ],
    ));
  }

  Widget _buildTopText() {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: EdgeInsets.only(top: 0),
        child: Text(
          topText,
          style: topTextStyle,
        ),
      ),
    );
  }

  Widget _buildBottomText() {
    return Padding(
      padding: EdgeInsets.only(bottom: 0),
      child: Row(children: [
        Visibility(
          child: Text(
            bottomText1,
            style: bottomText1Style,
          ),
          visible: bottomText1.isEmpty ? false : true,
        ),
        SizedBox(
          width: bottomText1.isEmpty ? 0 : 10.px,
        ),
        Visibility(
          child: Text(
            bottomText2,
            style: bottomText2Style,
          ),
          visible: bottomText2.isEmpty ? false : true,
        )
      ]),
    );
  }
}
