import 'package:flutter/material.dart';
import 'package:servicetracker_app/auth/auth_page.dart';
import 'package:servicetracker_app/pages/signIn.dart';

import '../core/index.dart';
import '../animations/fade_transition.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1300)).then((value) {
      if (context.mounted) {
        Navigator.pushNamed(context, '/auth');
      }
    });
  }

@override
Widget build(BuildContext context) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;
  final theme = Theme.of(context);
  final screenWidth = MediaQuery.of(context).size.width;

  // Example: 10% of screen width as padding
  final horizontalPadding = screenWidth * 0.1;

  return Scaffold(
    body: Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/Maintenance-Login-bg.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Align(
        alignment: Alignment.center,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Image.asset(
                //   isDarkMode ? AppIcon.logoDark : AppIcon.logoWhite,
                //   height: 130,
                //   width: 130,
                // ),
                const SizedBox(height: 15),
                Text(
                  'ICT Maintenance & Service Management',
                  style: theme.textTheme.headlineMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: Colors.white,
                    fontSize: 90,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
}
