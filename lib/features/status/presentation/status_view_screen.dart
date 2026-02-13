import 'package:flutter/material.dart';
import 'dart:io';

class StatusViewScreen extends StatelessWidget {
  final String userName;
  final String imagePath;

  const StatusViewScreen({
    super.key,
    required this.userName,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(userName, style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Image.file(File(imagePath)),
      ),
    );
  }
}
