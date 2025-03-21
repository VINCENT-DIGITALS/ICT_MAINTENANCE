import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraScreen extends StatefulWidget {
  final File? initialImage;

  const CameraScreen({Key? key, this.initialImage}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _cameraController;
  File? _capturedImage;

  @override
  void initState() {
    super.initState();
    if (widget.initialImage != null) {
      _capturedImage = widget.initialImage;
    } else {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _cameraController = CameraController(
      firstCamera,
      ResolutionPreset.high,
    );

    await _cameraController!.initialize();
    setState(() {});
  }

  Future<void> _captureImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;

    try {
      final pictureFile = await _cameraController!.takePicture();
      Navigator.pop(context, File(pictureFile.path));
    } catch (e) {
      print("Error capturing image: $e");
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _capturedImage != null
          ? Stack(
              children: [
                Positioned.fill(
                  child: Image.file(
                    _capturedImage!,
                    fit: BoxFit.cover, // Fullscreen image
                  ),
                ),
                Positioned(
                  top: 30,
                  left: 10,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context, _capturedImage),
                  ),
                ),
                Positioned(
                  bottom: 30,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _capturedImage = null;
                          _initializeCamera();
                        });
                      },
                      child: const Text("Take another photo"),
                    ),
                  ),
                ),
              ],
            )
          : (_cameraController == null || !_cameraController!.value.isInitialized)
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                  children: [
                    // ✅ FULLSCREEN Camera Preview with cropping
                    SizedBox.expand(
                      child: FittedBox(
                        fit: BoxFit.cover, // Ensures fullscreen with possible cropping
                        child: SizedBox(
                          width: _cameraController!.value.previewSize!.height,
                          height: _cameraController!.value.previewSize!.width,
                          child: CameraPreview(_cameraController!),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 30,
                      left: 10,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    Positioned(
                      bottom: 30,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: IconButton(
                          iconSize: 70,
                          icon: const Icon(Icons.camera_alt, color: Colors.white),
                          onPressed: _captureImage,
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
