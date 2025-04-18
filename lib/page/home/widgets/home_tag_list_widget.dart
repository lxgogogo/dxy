import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:holdem/utils/app_theme.dart';

import '../../../model/home_hot_tag_model.dart';

class HomeTagListWidget extends StatefulWidget {
  final List<HomeHotTagModel> tagList;
  final Function tagOnTap;
  const HomeTagListWidget(
      {super.key, required this.tagList, required this.tagOnTap});

  @override
  createState() => _HomeTagListWidgetState();
}

class _HomeTagListWidgetState extends State<HomeTagListWidget> {
  @override
  build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Wrap(
        spacing: 10.w,
        children: [
          ...widget.tagList.map((model) {
            return GestureDetector(
                onTap: () {
                  _onTap(model);
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                        height: 28.w,
                        padding: EdgeInsets.only(left: 20.w, right: 20.w),
                        alignment: Alignment.center,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(8.w)),
                            color: (model.select ?? false) ? Colors.white : Color(0xE5FFFFFF),
                            gradient: (model.select ?? false)
                                ? const LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                AppTheme.color_557BF6,
                                AppTheme.color_84BCF9,
                              ],
                              stops: [0, 1],
                            )
                                : null,
                            boxShadow: [
                              (model.select ?? false)
                                  ? BoxShadow(
                                  color:
                                  AppTheme.color_0050FF.withOpacity(0.2),
                                  offset: const Offset(0, 2),
                                  blurRadius: 8,
                                  spreadRadius: 0)
                                  : BoxShadow(
                                  color:
                                  AppTheme.color_333333.withOpacity(0.1),
                                  offset: const Offset(0, 4),
                                  blurRadius: 8,
                                  spreadRadius: 0)
                            ]),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 100.w),
                          child: Text(
                            model.name ?? '',
                            style: TextStyle(
                                fontSize: 12.sp,
                                color: (model.select ?? false)
                                    ? Colors.white
                                    : AppTheme.color_333333,
                                fontWeight: (model.select ?? false)
                                    ? FontWeight.w600
                                    : FontWeight.w400),
                          ),
                        ))
                  ],
                ));
          })
        ],
      )
    );
  }

  _onTap(model) {
    for (HomeHotTagModel m in widget.tagList) {
      m.select = false;
    }
    if (mounted) {
      setState(() {
        model.select = true;
      });
    }
    widget.tagOnTap(model);
  }
}
