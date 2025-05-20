import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:servicetracker_app/auth/auth_page.dart';
import 'package:servicetracker_app/pages/completedRequests/CompleteserviceDetails.dart';
import 'package:servicetracker_app/pages/completedRequests/completedRequests.dart';
import 'package:servicetracker_app/pages/home.dart';
import 'package:servicetracker_app/pages/incidentReports/incidentReportPage.dart';
import 'package:servicetracker_app/pages/incidentReports/newIncidentReport.dart';

 
import 'package:servicetracker_app/pages/myServices.dart';
import 'package:servicetracker_app/pages/ongoingRequests/equipmentDetails.dart';
import 'package:servicetracker_app/pages/ongoingRequests/ongoingRequests.dart';
import 'package:servicetracker_app/pages/ongoingRequests/UpdateStatusScreen.dart';
import 'package:servicetracker_app/pages/pendingRequests/pendingRequests.dart';
import 'package:servicetracker_app/pages/pickedRequests/pickedRequests.dart';
import 'package:servicetracker_app/pages/dumpPages/UpdateRequest.dart';
import 'package:servicetracker_app/pages/request/newRequest.dart';
import 'package:servicetracker_app/pages/request/newRequestManualQR.dart';
import 'package:servicetracker_app/pages/request/newRequestQR.dart';
import 'package:servicetracker_app/pages/ongoingRequests/serviceDetails.dart';
import 'package:servicetracker_app/pages/signIn.dart';
import 'package:servicetracker_app/services/FormProvider.dart';

import 'models/splash_screen.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  runApp(
    ChangeNotifierProvider(
      create: (context) => FormProvider(),
      child: const MyApp(),
    ),
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
//Navigator.pushNamed(context, '/EditIncidentReport'); //with backoption
//Navigator.pushReplacementNamed(context, '/newRequest'); //without back options
// ADD COWORKERS

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // Set the global navigator key
      debugShowCheckedModeBanner: false,
      initialRoute: '/', // Set the initial route
      routes: {
        '/': (context) => const SplashScreen(), // Default route
        '/auth': (context) => const AuthPage(), // Auth route
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/newRequest': (context) =>
            const NewRequest(), // Define newRequest route
        '/NewRequestQR': (context) => NewRequestQR(),
        '/ServiceDetails': (context) => const ServiceDetails(),
        '/NewRequestManualQR': (context) => const NewRequestManualQR(),
        '/UpdateRequest': (context) => const UpdateRequest(),
        '/MyServices': (context) => const MyServices(),
        '/IncidentReports': (context) => const IncidentReportPage(),
        '/PendingRequests': (context) => const PendingRequests(),
        '/PickedRequests': (context) => const PickedRequests(),
        '/OngoingRequests': (context) => const OngoingRequests(),
        // Add this to your MaterialApp routes
        '/EquipmentDetails': (context) => const EquipmentDetails(),
        '/CompletedRequests': (context) => const CompletedRequests(),
        'CompleteServiceDetails': (context) =>
            const CompleteServiceDetails(), // Add this to your MaterialApp routes
        '/UpdateStatusScreen': (context) => const UpdateStatusScreen(),
        '/NewIncidentReport': (context) =>
            const NewIncidentReport(), // Add this to your MaterialApp routes
      },
    );
  }
}
