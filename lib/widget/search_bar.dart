import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:holdem/utils/size_fit.dart';

class CSearchBar extends StatefulWidget {
  ValueChanged<String>? onSubmitted;
  ValueChanged<String>? onChanged;
  String? placeholder;
  bool hasPadding;

  CSearchBar(
      {super.key, this.hasPadding = true,this.placeholder='', this.onSubmitted, this.onChanged});

  @override
  State<CSearchBar> createState() => _CSearchBarState();
}

class _CSearchBarState extends State<CSearchBar> {
  String strKey = '';
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    SizeFit.initialize(context);
    // if(widget.hasPadding){
    //   return Padding(
    //       padding: EdgeInsets.only(left: 15.px, right: 15.px, top: 10.px, bottom: 10.px),
    //       child: searchContent()
    //   );
    // }
    return searchContent();
  }

  searchContent() {
    return Row(
      children: [
        Expanded(
          child: Container(
              width: 279.px,
              height: 32.px,
              padding: EdgeInsets.only(left: 15.px,right:12.px),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.px),
                boxShadow:  const [
                  BoxShadow(
                    color: Color(0x80BFD2E2),
                    offset: Offset(0, 5),
                    blurRadius: 10,
                  ),
                ],
                image: DecorationImage(
                      image: AssetImage('assets/images/input_bg.png'),
                      fit: BoxFit.contain)),
            child: Row(
              children: [
                // Icon(
                //   Icons.search,
                //   size: 20.px,
                //   color: const Color(0xff999999),
                // ),
                // SizedBox(
                //   width: 5.px,
                // ),
                Expanded(
                    child: TextField(
                  controller: searchController,
                  onChanged: (value) {
                    widget.onChanged?.call(value);
                    if (mounted) {
                      setState(() {
                        strKey = value;
                      });
                    }
                  },
                  onSubmitted: widget.onSubmitted,
                  cursorHeight: 14.px,
                  style: TextStyle(
                      height: 1, fontSize: 14.px, color: Color(0xff333333)),
                  decoration: InputDecoration(
                      // isDense: true,
                      // prefixIcon: Icon(Icons.search),
                      counterText: "",
                      hintText: widget.placeholder?.length==0?'请输入搜索内容':widget.placeholder,
                      border: InputBorder.none,
                      contentPadding: kIsWeb
                          ? EdgeInsets.only(bottom: 12)
                          : EdgeInsets.only(top: 8),
                      hintStyle: TextStyle(
                          color: const Color(0xFFBBBBBB),
                          fontSize: 14.px,
                          height: 1.0)),
                )),
                strKey.isNotEmpty
                    ? SizedBox(
                        width: 15.px,
                      )
                    : Container(),
                strKey.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          FocusManager.instance.primaryFocus?.unfocus();
                          widget.onChanged?.call('');
                          searchController.text = '';
                          if (mounted) {
                            setState(() {
                              strKey = '';
                            });
                          }
                        },
                        child: Image.asset(
                          'assets/images/clear.png',
                          width: 20.px,
                          height: 20.px,
                        ))
                    : Container(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
