import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:incubator/core/utils/screen_size.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:get/get.dart';
import '../controllers/media_controller.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  CameraController? _controller;
  List<CameraDescription> cameras = [];
  bool _isCameraInitialized = false;
  File? _capturedImage;

  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _currentScale = 1.0;
  double _baseScale = 1.0;
  int _pointers = 0;

  FlashMode _flashMode = FlashMode.off;
  List<FlashMode> flashModes = [
    FlashMode.off,
    FlashMode.always,
    FlashMode.torch,
  ];
  int _flashModeIndex = 0;

  bool _isOrientationLocked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      cameras = await availableCameras();
      if (cameras.isEmpty) return;

      _controller = CameraController(
        cameras[0],
        ResolutionPreset.max,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _controller!.initialize();

      _maxAvailableZoom = await _controller!.getMaxZoomLevel();
      _minAvailableZoom = await _controller!.getMinZoomLevel();

      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      print('Kamera başlatma hatası: $e');
    }
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _baseScale = _currentScale;
  }

  Future<void> _handleScaleUpdate(ScaleUpdateDetails details) async {
    if (_controller == null || _pointers != 2) return;

    _currentScale = (_baseScale * details.scale).clamp(
      _minAvailableZoom,
      _maxAvailableZoom,
    );
    await _controller!.setZoomLevel(_currentScale);
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      final XFile photo = await _controller!.takePicture();
      setState(() {
        _capturedImage = File(photo.path);
      });
    } catch (e) {
      print('Fotoğraf çekme hatası: $e');
    }
  }

  Future<void> _saveImage() async {
    if (_capturedImage == null) return;

    try {
      final directory = await getApplicationDocumentsDirectory();
      final String fileName =
          'IMG_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String filePath = path.join(directory.path, fileName);

      await _capturedImage!.copy(filePath);

      final mediaController = Get.find<MediaController>();
      mediaController.setImagePath(filePath);

      if (mounted) {
        Get.back();
      }
    } catch (e) {
      print('Resim kaydetme hatası: $e');
    }
  }

  void _toggleOrientationLock() {
    if (_isOrientationLocked) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
        DeviceOrientation.portraitDown,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
    setState(() {
      _isOrientationLocked = !_isOrientationLocked;
    });
  }

  void _cycleFlashMode() async {
    _flashModeIndex = (_flashModeIndex + 1) % flashModes.length;
    _flashMode = flashModes[_flashModeIndex];
    await _controller?.setFlashMode(_flashMode);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body:
          _capturedImage != null
              ? Stack(
                children: [
                  Center(
                    child: Image.file(_capturedImage!, fit: BoxFit.contain),
                  ),
                  Positioned(
                    bottom: ScreenSize.height * 0.03,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed:
                              () => setState(() => _capturedImage = null),
                          icon: Icon(
                            Icons.refresh,
                            size: ScreenSize.height * 0.025,
                            color: Colors.indigo,
                          ),
                          label: const Text(
                            'Yeniden Çek',
                            style: TextStyle(color: Colors.black),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _saveImage,
                          icon: Icon(
                            Icons.check,
                            size: ScreenSize.height * 0.025,
                            color: Colors.indigo,
                          ),
                          label: const Text(
                            'Kaydet',
                            style: TextStyle(color: Colors.black),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
              : Stack(
                children: [
                  Listener(
                    onPointerDown: (_) => _pointers++,
                    onPointerUp: (_) => _pointers--,
                    child: Center(
                      child: CameraPreview(
                        _controller!,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onScaleStart: _handleScaleStart,
                          onScaleUpdate: _handleScaleUpdate,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 70,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          onPressed: _cycleFlashMode,
                          icon: Icon(
                            _flashMode == FlashMode.off
                                ? Icons.flash_off
                                : _flashMode == FlashMode.always
                                ? Icons.flash_on
                                : Icons.highlight,
                            color: Colors.white,
                          ),
                        ),
                        GestureDetector(
                          onTap: _takePicture,
                          child: CircleAvatar(
                            radius: ScreenSize.height * 0.035,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.black,
                              size: ScreenSize.height * 0.045,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _toggleOrientationLock,
                          icon: Icon(
                            _isOrientationLocked
                                ? Icons.screen_lock_rotation
                                : Icons.screen_rotation,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }
}
