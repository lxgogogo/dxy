import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

class MyDropdownButton extends StatefulWidget {
  List<String> items = [];
  ValueChanged onChanged;

  MyDropdownButton({super.key, required this.items , required this.onChanged});

  @override
  _MyDropdownButtonState createState() => _MyDropdownButtonState();
}

class _MyDropdownButtonState extends State<MyDropdownButton> {
  String? _selectedValue;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      _selectedValue = widget.items[0];
    });
  }

  @override
  Widget build(BuildContext context) {
    // _selectedValue = widget.items[0];
    return DropdownButtonHideUnderline(
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
}
