
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:holdem/gen/assets.gen.dart';
import 'package:holdem/page/message/widgets/message_child_view.dart';
import 'package:holdem/utils/constants.dart';
import 'package:holdem/utils/log_util.dart';
import 'package:holdem/utils/size_fit.dart';
import 'package:holdem/widget/background_container.dart';

import '../../widget/dynamic_tabbar.dart';

part 'message_controller.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> with AutomaticKeepAliveClientMixin {
  List<TabData> parentTabs = [];
  int selIndex = 0;

  final List<Tab> myTabs = const <Tab>[
    Tab(text: '@我的'),
    Tab(text: '评论我的'),
    Tab(text: '点赞我的'),
    Tab(text: '收藏我的'),
  ];
  final List<String> tabs = ['@我的', '评论我的', '赞我的', '收藏'];
  final List<String> types = [ 'at','comment', 'like', 'favorite',];
  final _pageKey = GlobalKey<MessageChildViewState>();

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < myTabs.length; i++) {
      parentTabs.add(TabData(
        index: i,
        title: Tab(
          child: Stack(
            children: [
              Container(
                  padding: EdgeInsets.only(right: 4.w),
                  child: Center(child: Text(myTabs[i].text.toString()))),
              Visibility(
                visible: false,
                child: Positioned(
                    right: 1,
                    top:10,
                    child: Container(
                  width: 8,
                  height: 8,
                  decoration: const ShapeDecoration(
                    color: Color(0xFFFF3232),
                    shape: OvalBorder(),
                  ),
                )),
              )
            ],
          ),
          // child: Text(myTabs[i].text.toString()),
        ),
        content: MessageChildView(type: types[i]),
      ));
    }
  }

  Widget getTabView() {
    return DynamicTabBarWidget(
      dynamicTabs: parentTabs,
      isScrollable: true,
      showBackIcon: false,
      showNextIcon: false,
      padding: EdgeInsets.only(bottom: 8.w),
      labelPadding:  EdgeInsets.fromLTRB(16.w, 0, 10, 0),
      indicatorColor: '#557BF6'.hexColor,
      indicatorPadding: const EdgeInsets.symmetric(horizontal:35,vertical:5),
      indicatorSize: TabBarIndicatorSize.tab,
      tabAlignment: TabAlignment.start,
      //底部下标颜色
      enableFeedback: true,
      dividerHeight: 0,
      labelStyle: TextStyle(height: 1, color: '#333333'.hexColor, fontSize: 14.w, fontWeight: FontWeight.w600),
      unselectedLabelStyle:
          TextStyle(height: 1, color: '#333333'.hexColor.withOpacity(0.7), fontSize: 14.w, fontWeight: FontWeight.w600),
      onTabChanged: (index) {
        Log.d('tab');
        setState(() {
          selIndex = index!;
        });
      },
      trailing: SizedBox(),
      onTabControllerUpdated: (TabController) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(
      //     '消息',
      //     style: TextStyle(
      //       color: const Color(0xff2c2c2c),
      //       fontSize: 16.w,
      //       fontWeight: FontWeight.w500,
      //     ),
      //   ),
      //   centerTitle: true,
      //   backgroundColor: Colors.white,
      //   elevation: 0,
      // ),
      backgroundColor: Colors.transparent,
      body:  SafeArea(child: getTabView()),
    );
  }

  Widget detail() {
    return Column(
      children: [
        SafeArea(
          bottom: false,
          child: Container(
              width: double.infinity,
              child: getTabView()),
        ),
       // SingleChildScrollView(
       //    scrollDirection: Axis.horizontal,
       //    child: Row(
       //      children: [
       //        SizedBox(
       //          width: 18.w,
       //        ),
              // ...List.generate(tabs.length, (index) {
              //   return GestureDetector(
              //     onTap: () {
              //       setState(() {
              //         selIndex = index;
              //       });
              //       _pageKey.currentState?.refreshData(types[selIndex]);
              //     },
              //     child: Container(
              //       height: 30.w,
              //       padding: EdgeInsets.symmetric(horizontal: 17.w),
              //       margin: EdgeInsets.only(right: 12.w, bottom: 12.w),
              //       alignment: Alignment.center,
              //       decoration: BoxDecoration(
              //           borderRadius: BorderRadius.circular(15.w),
              //           boxShadow: [
              //             BoxShadow(
              //               color: selIndex == index ? const Color(0xFFC8D4EE) : const Color(0xFFd6e2f0),
              //               spreadRadius: 0,
              //               blurRadius: 10,
              //               offset: Offset(0, 3), // changes position of shadow
              //             ),
              //           ],
              //           gradient: LinearGradient(
              //             begin: Alignment.topCenter,
              //             end: Alignment.bottomCenter,
              //             colors: selIndex == index
              //                 ? const [
              //                     Color(0xFF75BFFF),
              //                     Color(0xFF48AAFF),
              //                     Color(0xFF479DFF),
              //                     Color(0xFF3B91F1),
              //                   ]
              //                 : const [
              //                     Color(0xFFF5F8FF),
              //                     Color(0xFFECF3FF),
              //                   ],
              //           )),
              //       child: Text(
              //         tabs[index],
              //         style:
              //             TextStyle(color: selIndex == index ? Colors.white : const Color(0xff95A3C4), fontSize: 14.w),
              //       ),
              //     ),
              //   );
             // })

       //     ],
        //   ),
        // ),

        // Expanded(
        //     child: MessageChildView(
        //   type: types[selIndex],
        //   key: _pageKey,
        // ))
      ],
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
