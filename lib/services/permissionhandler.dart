import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionHandlerPage extends StatefulWidget {
  const PermissionHandlerPage({Key? key}) : super(key: key);

  @override
  _PermissionHandlerPageState createState() => _PermissionHandlerPageState();
}

class _PermissionHandlerPageState extends State<PermissionHandlerPage> {
  bool isCameraGranted = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions(); // Automatically check permissions on startup
  }

  /// 🔥 **Check and Request Camera Permission**
  Future<void> _checkPermissions() async {
    var status = await Permission.camera.status;
    
    if (status.isGranted) {
      setState(() => isCameraGranted = true);
    } else if (status.isDenied || status.isRestricted)  {
      await Permission.camera.request();
      setState(() async => isCameraGranted = await Permission.camera.isGranted);
    } else if (status.isPermanentlyDenied) {
      _showSettingsDialog();
    }
  }

  /// 🔥 **Show Dialog for Permanently Denied Permission**
  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Permission Required"),
        content: const Text(
            "Camera permission is permanently denied. Please enable it from settings."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              openAppSettings(); // Redirect to App Settings
              Navigator.pop(context);
            },
            child: const Text("Open Settings"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Permissions Example")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isCameraGranted ? Icons.check_circle : Icons.cancel,
              color: isCameraGranted ? Colors.green : Colors.red,
              size: 80,
            ),
            const SizedBox(height: 20),
            Text(
              isCameraGranted ? "Camera Permission Granted" : "Camera Permission Denied",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _checkPermissions,
              child: const Text("Check Permission Again"),
            ),
          ],
        ),
      ),
    );
  }
}
