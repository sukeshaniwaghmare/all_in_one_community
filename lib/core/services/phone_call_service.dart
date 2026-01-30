import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';

class PhoneCallService {
  static Future<bool> makeCall(String phoneNumber, BuildContext context) async {
    if (phoneNumber.isEmpty) {
      _showSnackBar(context, 'No phone number available');
      return false;
    }

    // Request phone permission
    final permission = await Permission.phone.request();
    if (!permission.isGranted) {
      _showSnackBar(context, 'Phone permission is required to make calls');
      return false;
    }

    try {
      final Uri callUri = Uri.parse('tel:$phoneNumber');
      if (await canLaunchUrl(callUri)) {
        await launchUrl(callUri);
        return true;
      } else {
        _showSnackBar(context, 'Cannot make call to this number');
        return false;
      }
    } catch (e) {
      _showSnackBar(context, 'Error making call: $e');
      return false;
    }
  }

  static void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}