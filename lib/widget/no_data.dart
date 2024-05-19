import 'package:flutter/material.dart';

class NoDataView extends StatefulWidget {
  const NoDataView({super.key});

  @override
  State<NoDataView> createState() => _NoDataViewState();
}

class _NoDataViewState extends State<NoDataView> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/images/no_data.png', width: 90, height: 90),
        const SizedBox(height: 15,),
        const Text('暂无数据',style: TextStyle(color: Color(0xff333333),fontSize: 15),)
      ],
    );
  }
}