import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NoNetworkView extends StatelessWidget {
  final String text;
  final VoidCallback? onRefresh;

  const NoNetworkView({
    super.key,
    this.text = '无法连接到网络',
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: onRefresh,
            icon: Icon(
              Icons.refresh,
              color: const Color(0xff3b5078),
              size: 28.sp,
            ),
          ),
          Text(
            text,
            style: TextStyle(
              color: const Color(0xff3b5078),
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }
}
