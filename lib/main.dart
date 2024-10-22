import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_splash_screen/flutter_splash_screen.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:get/get.dart';
import 'package:holdem/page/forum/page_forum_post_detail.dart';
import 'package:holdem/page/index/page_article_detail.dart';
import 'package:holdem/page/index/page_book_detail.dart';
import 'package:holdem/page/index/page_video_detail.dart';
import 'package:holdem/page/index/page_video_list.dart';
import 'package:holdem/page/main_page.dart';
import 'package:holdem/utils/app_theme.dart';
import 'package:holdem/utils/common_utils.dart';
import 'package:holdem/utils/global.dart';
import 'package:holdem/utils/storage.dart';
import 'package:oktoast/oktoast.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
void main() {
  usePathUrlStrategy();
  runApp(const MyApp());
  initStore();
}

Future<void> initStore() async {
  await StorageUtil().init();
  if (StorageUtil().prefs!.getString("token") != null) {
    Global().hasLogin = true;
    Global().token = StorageUtil().prefs!.getString("token")!;
    print('has Login');
  }
}

///hide your splash screen
Future<void> hideScreen() async {
  Future.delayed(const Duration(milliseconds: 2000), () {
    FlutterSplashScreen.hide();
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    if (CommonUtils.isAndroid(context)) {
      hideScreen();
    }
    // EasyLoading.init();
    return OKToast(
        child: GetMaterialApp(
          title: '德学院',
          debugShowCheckedModeBanner: false,
          localizationsDelegates: const [
            // 这行是关键
            RefreshLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalMaterialLocalizations.delegate

          ],
          supportedLocales: const [
            Locale('zh'),
            Locale('en'),

          ],
          localeResolutionCallback:
              (locale, Iterable<Locale> supportedLocales) {
            //print("change language");
            return locale;
          },
          theme: ThemeData(
            // This is the theme of your application.
            //
            // TRY THIS: Try running your application with "flutter run". You'll see
            // the application has a blue toolbar. Then, without quitting the app,
            // try changing the seedColor in the colorScheme below to Colors.green
            // and then invoke "hot reload" (save your changes or press the "hot
            // reload" button in a Flutter-supported IDE, or press "r" if you used
            // the command line to start the app).
            //
            // Notice that the counter didn't reset back to zero; the application
            // state is not lost during the reload. To reset the state, use hot
            // restart instead.
            //
            // This works for code too, not just values: Most code changes can be
            // tested with just a hot reload.
              colorScheme: ColorScheme.fromSeed(seedColor: AppTheme.color_008EFF),
              useMaterial3: true,
              visualDensity: VisualDensity.compact,
              focusColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hintColor: Colors.transparent,
              hoverColor: Colors.transparent,
              splashColor: Colors.transparent,
              appBarTheme: AppBarTheme(scrolledUnderElevation: 0.0,
                  titleTextStyle: TextStyle(fontSize: 16,color: const Color(0xff2C2C2C))
              )
            // 设置最大宽度为 960px
            // 可根据需求调整该值
          ),
          // home: WebFitPage(child: SplashScreen()),
          builder: EasyLoading.init(),
          initialRoute: '/',
          routes: {
            // '/': (context) => MainScreen(),
            '/': (context) => MainScreen(),
            '/book_detail': (context) => BookDetailPage(
                id: int.parse(
                    ModalRoute.of(context)!.settings.arguments.toString())),
            '/article_detail': (context) => ArticleDetailPage(
                id: int.parse(
                    ModalRoute.of(context)!.settings.arguments.toString())),
            '/video_detail': (context) => VideoDetailPage(
                id: int.parse(
                    ModalRoute.of(context)!.settings.arguments.toString())),
            '/video_list': (context) => VideoListPage(
                id: int.parse(
                    ModalRoute.of(context)!.settings.arguments.toString())),
            '/post_detail': (context) => PostDetailPage(
                postId: int.parse(
                    ModalRoute.of(context)!.settings.arguments.toString())),
          },
          onGenerateRoute: (settings) {
            final Uri uri = Uri.parse(settings.name!);
            final String path = uri.path;
            final Map<String, String> parameters = uri.queryParameters;

            switch (path) {
              case '/book_detail':
                return MaterialPageRoute(
                  builder: (context) =>
                      BookDetailPage(id: int.parse(parameters['id']!)),
                );
              case '/article_detail':
                return MaterialPageRoute(
                  builder: (context) =>
                      ArticleDetailPage(id: int.parse(parameters['id']!)),
                );
              case '/video_detail':
                return MaterialPageRoute(
                  builder: (context) =>
                      VideoDetailPage(id: int.parse(parameters['id']!)),
                );
              case '/video_list':
                return MaterialPageRoute(
                  builder: (context) =>
                      VideoListPage(id: int.parse(parameters['id']!)),
                );
              case '/post_detail':
                return MaterialPageRoute(
                  builder: (context) =>
                      PostDetailPage(postId: int.parse(parameters['postId']!)),
                );
            }
          },
        ));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
