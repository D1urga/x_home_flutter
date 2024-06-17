import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:x_home/Notification.dart';
import 'package:x_home/home_page.dart';
import 'package:x_home/login_page.dart';
import 'package:x_home/profile.dart';
import 'package:x_home/search_page.dart';
import 'package:x_home/upload_page.dart';
import 'package:x_home/login_page.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var email = prefs.getString("email");
  print(email);
  HttpOverrides.global = MyHttpOverrides();
  runApp(MyApp(
    email: email,
  ));
}

class MyApp extends StatelessWidget {
  final String? email;
  const MyApp({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          theme: ThemeData(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: email == null
              ? LoginPage()
              : const MyHomePage(title: 'Flutter Demo Home Page'),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    const SearchPage(),
    const UploadPage(),
    const UserNotifications(),
    UserProfile()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: IndexedStack(index: _selectedIndex, children: _widgetOptions)),
      bottomNavigationBar: Container(
        height: 50,
        decoration: const BoxDecoration(
            border: Border(
                top: BorderSide(
                    color: Color.fromARGB(255, 199, 199, 199), width: 0.5))),
        child: BottomNavigationBar(
          elevation: 0,
          backgroundColor: Colors.white,
          showSelectedLabels: false,
          selectedFontSize: 0,
          unselectedFontSize: 0,
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels: false,
          items: const [
            BottomNavigationBarItem(
              icon: FaIcon(
                FontAwesomeIcons.house,
                size: 20,
              ),
              label: 'Profile',
            ),
            BottomNavigationBarItem(
              icon: FaIcon(
                FontAwesomeIcons.magnifyingGlass,
                size: 21,
              ),
              label: 'Profile',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.add_circle,
                size: 26,
              ),
              label: 'Profile',
            ),
            BottomNavigationBarItem(
              icon: FaIcon(
                FontAwesomeIcons.solidBell,
                size: 22,
              ),
              label: 'Profile',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.person_rounded,
                size: 25,
              ),
              label: 'Profile',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.black,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
