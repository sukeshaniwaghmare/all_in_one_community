import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  bool _isVideo = false;
  bool _isFlashOn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.grey[800],
            child: const Center(
              child: Icon(Icons.camera_alt, size: 100, color: Colors.white54),
            ),
          ),
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
          IconButton(
            icon: Icon(_isFlashOn ? Icons.flash_on : Icons.flash_off, color: Colors.white, size: 28),
            onPressed: () => setState(() => _isFlashOn = !_isFlashOn),
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
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.photo_library, color: Colors.white),
          ),
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: _isVideo ? Colors.red : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
              ),
              child: _isVideo 
                ? const Icon(Icons.stop, color: Colors.white, size: 30)
                : null,
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
              child: Icon(
                _isVideo ? Icons.camera_alt : Icons.videocam,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}