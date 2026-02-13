import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/theme/app_theme.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isVideo = false;
  bool _isRecording = false;
  FlashMode _flashMode = FlashMode.off;
  int _selectedCamera = 0;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras!.isNotEmpty) {
        await _setupCamera(_cameras![_selectedCamera]);
      }
    } catch (e) {
      debugPrint('Camera init error: $e');
    }
  }

  Future<void> _setupCamera(CameraDescription camera) async {
    _controller = CameraController(camera, ResolutionPreset.high, enableAudio: true);
    try {
      await _controller!.initialize();
      await _controller!.setFlashMode(_flashMode);
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Camera setup error: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _toggleFlash() async {
    if (_controller == null) return;
    setState(() {
      _flashMode = _flashMode == FlashMode.off ? FlashMode.torch : FlashMode.off;
    });
    await _controller!.setFlashMode(_flashMode);
  }

  Future<void> _switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) return;
    _selectedCamera = (_selectedCamera + 1) % _cameras!.length;
    await _controller?.dispose();
    await _setupCamera(_cameras![_selectedCamera]);
  }

  Future<void> _capturePhoto() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    try {
      final image = await _controller!.takePicture();
      if (mounted) {
        Navigator.pop(context, image.path);
      }
    } catch (e) {
      debugPrint('Capture error: $e');
    }
  }

  Future<void> _toggleRecording() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    try {
      if (_isRecording) {
        final video = await _controller!.stopVideoRecording();
        setState(() => _isRecording = false);
        if (mounted) Navigator.pop(context, video.path);
      } else {
        await _controller!.startVideoRecording();
        setState(() => _isRecording = true);
      }
    } catch (e) {
      debugPrint('Recording error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          SizedBox.expand(child: CameraPreview(_controller!)),
          SafeArea(
            child: Column(
              children: [
                _buildTopControls(),
                const Spacer(),
                _buildBottomControls(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopControls() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(_flashMode == FlashMode.torch ? Icons.flash_on : Icons.flash_off, color: Colors.white, size: 28),
                onPressed: _toggleFlash,
              ),
              if (_cameras != null && _cameras!.length > 1)
                IconButton(
                  icon: const Icon(Icons.flip_camera_ios, color: Colors.white, size: 28),
                  onPressed: _switchCamera,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const SizedBox(width: 50),
          GestureDetector(
            onTap: _isVideo ? _toggleRecording : _capturePhoto,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: _isRecording ? Colors.red : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
              ),
              child: _isRecording ? const Icon(Icons.stop, color: Colors.white, size: 30) : null,
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _isVideo = !_isVideo),
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _isVideo ? AppTheme.primaryColor : Colors.white24,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(_isVideo ? Icons.camera_alt : Icons.videocam, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}