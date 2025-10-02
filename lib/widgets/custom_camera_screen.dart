import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:meu_tempo/views/photo_preview_screen.dart';
import 'package:meu_tempo/widgets/custom_loading.dart';
import 'package:permission_handler/permission_handler.dart';

class CustomCameraScreen extends StatefulWidget {
  const CustomCameraScreen({super.key});

  @override
  State<CustomCameraScreen> createState() => _CustomCameraScreenState();
}

class _CustomCameraScreenState extends State<CustomCameraScreen> {
  late List<CameraDescription> _cameras;
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  int _currentCameraIndex = 0;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _requestPermission().then((_) => _initCameras());
  }

  Future<void> _requestPermission() async {
    final status = await Permission.camera.status;
    if (!status.isGranted) {
      await Permission.camera.request();
    }
  }

  Future<void> _initCameras() async {
    _cameras = await availableCameras();
    await _initCamera(_currentCameraIndex);
  }

  Future<void> _initCamera(int cameraIndex) async {
    _controller = CameraController(
      _cameras[cameraIndex],
      ResolutionPreset.ultraHigh,
      enableAudio: false,
    );

    _initializeControllerFuture = _controller.initialize();
    await _initializeControllerFuture;

    if (mounted) {
      setState(() => _isCameraInitialized = true);
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length > 1) {
      _currentCameraIndex = (_currentCameraIndex + 1) % _cameras.length;
      await _controller.dispose();
      await _initCamera(_currentCameraIndex);
    }
  }

  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;
      final image = await _controller.takePicture();

      final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PhotoPreviewScreen(imagePath: image.path)),
      );

      if (result != null && result is String) {
        Navigator.pop(context, result);
      }
    } catch (e) {
      debugPrint('Erro ao tirar foto: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: !_isCameraInitialized
          ? const Center(child: CustomLoadingWidget())
          : FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Stack(
                    children: [
                      Positioned.fill(
                        child: FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: _controller.value.previewSize!.height,
                            height: _controller.value.previewSize!.width,
                            child: CameraPreview(_controller),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 20,
                        left: 20,
                        child: FloatingActionButton(
                          heroTag: 'switchCamera',
                          onPressed: _switchCamera,
                          child: const Icon(Icons.cameraswitch),
                        ),
                      ),
                      Positioned(
                        bottom: 20,
                        right: 20,
                        child: FloatingActionButton(
                          heroTag: 'takePicture',
                          onPressed: _takePicture,
                          child: const Icon(Icons.camera_alt_outlined),
                        ),
                      ),
                    ],
                  );
                } else {
                  return const Center(child: CustomLoadingWidget());
                }
              },
            ),
    );
  }
}
