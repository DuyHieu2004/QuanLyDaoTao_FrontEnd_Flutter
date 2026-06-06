import 'package:flutter/material.dart';

import 'package:intl/date_symbol_data_local.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('vi_VN', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'App Đăng Nhập',
      theme: ThemeData(
        primaryColor: const Color(0xFFC89B53),
        scaffoldBackgroundColor: Colors.transparent,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          iconTheme: const IconThemeData(color: Color(0xFFC89B53)),
          titleTextStyle: const TextStyle(color: Color(0xFFC89B53), fontSize: 18, fontWeight: FontWeight.bold),
          elevation: 0,
        ),
      ),
      builder: (context, child) {
        return Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/background.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: child,
        );
      },
      home: const LoginScreen(),
    );
  }
}


