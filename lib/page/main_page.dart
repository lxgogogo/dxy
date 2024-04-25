import 'package:flutter/material.dart';
import 'package:holdem/utils/size_fit.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final List<Widget> _pages = [Page1(), Page2(), Page3(), Page4()];

  @override
  Widget build(BuildContext context) {
    SizeFit.initialize(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('TabBar Demo'),
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        elevation: 0.0,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        selectedItemColor: const Color(0xff008EFF),
        unselectedItemColor: const Color(0xff3B5078),
        showSelectedLabels: true, // 取消显示选中项的标签
          showUnselectedLabels: true, // 取消显示未选中项的标签
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(
              _currentIndex == 0
                  ? 'assets/images/tab_index_sel.png'
                  : 'assets/images/tab_index.png',
              width: 38.px,
              height: 40.px,
            ),
            label: 'Page 1',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              _currentIndex == 1
                  ? 'assets/images/tab_forum_sel.png'
                  : 'assets/images/tab_forum.png',
              width: 38.px,
              height: 40.px,
            ),
            label: 'Page 2',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              _currentIndex == 2
                  ? 'assets/images/tab_message_sel.png'
                  : 'assets/images/tab_message.png',
              width: 38.px,
              height: 40.px,
            ),
            label: 'Page 3',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              _currentIndex == 3
                  ? 'assets/images/tab_me_sel.png'
                  : 'assets/images/tab_me.png',
              width: 38.px,
              height: 40.px,
            ),
            label: 'Page 4',
          ),
        ],
      ),
    );
  }
}

class Page1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('a');
    return Center(
      child: Text('Page 1'),
    );
  }
}

class Page2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Page 2'),
    );
  }
}

class Page3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Page 3'),
    );
  }
}

class Page4 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Page 4'),
    );
  }
}
