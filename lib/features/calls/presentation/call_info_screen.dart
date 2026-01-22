import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class CallInfoScreen extends StatelessWidget {
  final String name;
  final String avatar;
  final Color color;
  final bool isVideo;

  const CallInfoScreen({
    super.key,
    required this.name,
    required this.avatar,
    required this.color,
    required this.isVideo,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.8),
                  Colors.black,
                ],
              ),
            ),
          ),
          
          // Main content
          Column(
            children: [
              // Top section with back button and menu
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: Colors.white),
                        onSelected: (value) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(value)),
                          );
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'Add to contacts', child: Text('Add to contacts')),
                          const PopupMenuItem(value: 'Block', child: Text('Block')),
                          const PopupMenuItem(value: 'Report', child: Text('Report')),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const Spacer(),
              
              // Profile section
              Column(
                children: [
                  CircleAvatar(
                    radius: 80,
                    backgroundColor: color,
                    child: Text(
                      avatar,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isVideo ? 'WhatsApp video calling...' : 'WhatsApp calling...',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              
              const Spacer(),
              
              // Bottom controls
              Padding(
                padding: const EdgeInsets.only(bottom: 60),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Mute button
                    _buildControlButton(
                      icon: Icons.mic_off,
                      onPressed: () {},
                      backgroundColor: Colors.white.withOpacity(0.2),
                    ),
                    
                    // End call button
                    _buildControlButton(
                      icon: Icons.call_end,
                      onPressed: () => Navigator.pop(context),
                      backgroundColor: Colors.red,
                      size: 70,
                    ),
                    
                    // Speaker button
                    _buildControlButton(
                      icon: Icons.volume_up,
                      onPressed: () {},
                      backgroundColor: Colors.white.withOpacity(0.2),
                    ),
                  ],
                ),
              ),
              
              // Additional controls for video call
              if (isVideo)
                Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildControlButton(
                        icon: Icons.videocam_off,
                        onPressed: () {},
                        backgroundColor: Colors.white.withOpacity(0.2),
                      ),
                      _buildControlButton(
                        icon: Icons.flip_camera_ios,
                        onPressed: () {},
                        backgroundColor: Colors.white.withOpacity(0.2),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color backgroundColor,
    double size = 60,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: size * 0.4,
        ),
      ),
    );
  }
}