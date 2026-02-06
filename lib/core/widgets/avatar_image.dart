import 'dart:io';
import 'package:flutter/material.dart';

class AvatarImage extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final String fallbackText;
  final Color? backgroundColor;
  final Color? textColor;

  const AvatarImage({
    super.key,
    this.imageUrl,
    this.radius = 20,
    this.fallbackText = 'U',
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? Colors.blueGrey,
      backgroundImage: _getImageProvider(),
      child: _getImageProvider() == null
          ? Text(
              fallbackText,
              style: TextStyle(
                color: textColor ?? Colors.white,
                fontSize: radius * 0.8,
              ),
            )
          : null,
    );
  }

  ImageProvider? _getImageProvider() {
    if (imageUrl == null || imageUrl!.isEmpty) return null;
    
    if (imageUrl!.startsWith('http://') || imageUrl!.startsWith('https://')) {
      return NetworkImage(imageUrl!);
    } else {
      return FileImage(File(imageUrl!));
    }
  }
}
