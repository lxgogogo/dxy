import 'package:flutter/material.dart';
import 'package:holdem/utils/size_fit.dart';

class NoDataView extends StatelessWidget {
  final String text;

  const NoDataView({super.key, this.text = '暂无数据'});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/images/no_result.png',  height: 102.px),
        SizedBox(
          height: 10.px,
        ),
        Text(
          text,
          style: const TextStyle(
            color: Color(0xff5d6e8e),
            fontSize: 12,
          ),
        )
      ],
    );
  }
}