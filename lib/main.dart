import 'package:flutter/material.dart';
import 'package:servicetracker_app/pages/home.dart';
import 'package:servicetracker_app/pages/request/newRequest.dart';
import 'package:servicetracker_app/pages/request/newRequestQR.dart';
import 'package:servicetracker_app/pages/request/newRequestSave.dart';
import 'package:servicetracker_app/pages/serviceDetails.dart';
import 'package:servicetracker_app/pages/signIn.dart';

import 'models/splash_screen.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }
//Navigator.pushNamed(context, '/newRequest'); //with backoption
//Navigator.pushReplacementNamed(context, '/newRequest'); //without back options

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // Set the global navigator key
      debugShowCheckedModeBanner: false,
      initialRoute: '/', // Set the initial route
      routes: {
        '/': (context) => const SplashScreen(), // Default route
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/newRequest': (context) =>
            const NewRequest(), // Define newRequest route
        '/NewRequestQR': (context) => const NewRequestQR(),
        '/NewRequestSave': (context) => const NewRequestSave(),
        '/ServiceDetails' : (context) => const ServiceDetails(),
      },
    );
  }
}
