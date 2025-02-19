import 'dart:async';
import 'package:flutter/material.dart';
import 'package:servicetracker_app/pages/home.dart';
import 'package:servicetracker_app/pages/signIn.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  // late final StreamSubscription<User?> _authSubscription;
  // late final Timer _loadingTimeout;
  // StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  bool _hasNavigated = false;
  @override
  void initState() {
    super.initState();
    _navigateToLoginPage();
  }

  @override
  void dispose() {
    // _authSubscription.cancel();
    // _loadingTimeout.cancel();
    // _connectivitySubscription.cancel();
    super.dispose();
  }

  void _navigateToLoginPage() {
    if (!_hasNavigated && mounted) {
      _hasNavigated = true;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  void _navigateToHomePage() {
    if (!_hasNavigated && mounted) {
      _hasNavigated = true;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
