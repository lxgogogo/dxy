import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:holdem/utils/size_fit.dart';

import '../utils/app_theme.dart';

class MyDropdownButton extends StatefulWidget {
  List<String> items = [];
  ValueChanged onChanged;
  MyDropdownButton({super.key, required this.items, required this.onChanged});

  @override
  _MyDropdownButtonState createState() => _MyDropdownButtonState();
}

class _MyDropdownButtonState extends State<MyDropdownButton> {
  String? _selectedValue;
  int filterIndex = 0;

  @override
  void initState() {
    super.initState();
    setState(() {
      _selectedValue = widget.items[0];
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showMenuDialog(context);
      },
      child: Row(
        children: [
          const Spacer(),
          Text(
            _selectedValue ?? "",
            style: AppTheme.text666666Size15,
          ),
          const Padding(
            padding: EdgeInsets.only(left: 20),
            child: Icon(Icons.arrow_drop_down),
          )
        ],
      ),
    );
    DropdownButtonHideUnderline(
      child: DropdownButton2<String>(
        isExpanded: true,
        hint: Text(
          '选择板块',
          style: AppTheme.text666666Size15,
        ),
        items: widget.items
            .map((String item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: AppTheme.text333333Size15,
                  ),
                ))
            .toList(),
        value: _selectedValue,
        onChanged: (String? value) {
          widget.onChanged(value);
          if (mounted) {
            setState(() {
              _selectedValue = value;
            });
            print(_selectedValue);
          }
        },
        buttonStyleData: const ButtonStyleData(
          padding: EdgeInsets.symmetric(horizontal: 16),
          height: 40,
          width: 120,
        ),
        menuItemStyleData: const MenuItemStyleData(
          height: 40,
        ),
      ),
    );
  }

  void _showMenuDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true, // 可以点击外部区域关闭弹窗
      barrierLabel: '',
      barrierColor: Colors.transparent, // 背景遮罩颜色
      transitionDuration: Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.topRight, // 弹窗位置
          child: Container(
            width: 90.px,
            height: 133.px,
            margin: EdgeInsets.only(top: 75.px, right: 5), // 自定义位置
            padding: EdgeInsets.only(top: 10.px, bottom: 13.px),
            decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/images/pop_menu_bg.png'),
                  fit: BoxFit.cover),
            ),
            child: Column(
                children: widget.items
                    .map((item) => Expanded(
                            child: Column(
                          children: [
                            Expanded(
                                child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  filterIndex = widget.items.indexOf(item);
                                });

                                Navigator.of(context).pop(); // 关闭弹窗

                                widget.onChanged(widget.items[filterIndex]);
                                if (mounted) {
                                  setState(() {
                                    _selectedValue = widget.items[filterIndex];
                                  });
                                }
                              },
                              child: Container(
                                  color: Colors.transparent,
                                  child: Center(
                                      child: Text(
                                    item,
                                    style: TextStyle(
                                        color: filterIndex ==
                                                widget.items.indexOf(item)
                                            ? Color(0xff249CFC)
                                            : Color(0xff95A3C4)),
                                  ))),
                            )),
                            Container(
                              width: 90.px,
                              height: 0.5.px,
                              color: const Color(0xffE7F0FA),
                            )
                          ],
                        )))
                    .toList()),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: Tween(begin: 0.0, end: 1.0).animate(anim1),
          child: child,
        );
      },
    );
  }
}
