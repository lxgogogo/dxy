import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:holdem/utils/size_fit.dart';


///
/// 左侧圆形头像，右侧顶部text，右侧底部2个text
///
class CircleImageWithText extends StatelessWidget {
  final String imageUrl;
  final String topText;
  final String bottomText1;
  final String bottomText2;

  CircleImageWithText(
      {required this.imageUrl,
      required this.topText,
      required this.bottomText1,
      required this.bottomText2});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(10.0),
          child: ClipOval(
            child: Image.network(
              imageUrl,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildTopText(),
            _buildBottomText(),
          ],
        ),
      ],
    ));
  }

  Widget _buildTopText() {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: EdgeInsets.only(top: 10.0),
        child: Text(
          topText,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomText() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.only(bottom: 10.0),
        child: Row(children: [
          Text(bottomText1),
          SizedBox(
            width: 10.px,
          ),
          Text(bottomText2)
        ]),
      ),
    );
  }
}
