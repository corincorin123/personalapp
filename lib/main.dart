import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:personal_application/Diary/diaryScreen.dart';
import 'package:personal_application/Weather/weatherScreen.dart';

import 'package:personal_application/authPage/LoginPage.dart';
import 'package:personal_application/authPage/RegisterPage.dart';
import 'package:personal_application/bottomNavigationBar.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
      ),
      initialRoute: Loginpage.id,
      routes: {
        Loginpage.id: (context) => Loginpage(),
        Registerpage.id: (context) => Registerpage(),
        Diaryscreen.id: (context) => Diaryscreen(),
        BottomNav.id: (context) => BottomNav(),
        Weatherscreen.id: (context) => Weatherscreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
