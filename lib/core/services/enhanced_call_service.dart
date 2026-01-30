import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../features/calls/presentation/real_calling_screen.dart';

class CallService {
  static const String _callHistoryKey = 'call_history';
  
  // Make a real phone call
  static Future<bool> makePhoneCall(String phoneNumber, BuildContext context) async {
    if (phoneNumber.isEmpty) {
      _showSnackBar(context, 'No phone number available');
      return false;
    }

    final permission = await Permission.phone.request();
    if (!permission.isGranted) {
      _showSnackBar(context, 'Phone permission required');
      return false;
    }

    try {
      final Uri callUri = Uri.parse('tel:$phoneNumber');
      if (await canLaunchUrl(callUri)) {
        await launchUrl(callUri);
        await _saveCallHistory(phoneNumber, 'outgoing', false);
        return true;
      } else {
        _showSnackBar(context, 'Cannot make call');
        return false;
      }
    } catch (e) {
      _showSnackBar(context, 'Error: $e');
      return false;
    }
  }

  // Start WhatsApp-like call interface
  static Future<void> startCall({
    required BuildContext context,
    required String contactName,
    required String phoneNumber,
    String? profileImage,
    bool isVideo = false,
    bool isIncoming = false,
  }) async {
    await _saveCallHistory(phoneNumber, isIncoming ? 'incoming' : 'outgoing', isVideo);
    
    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RealCallingScreen(
            contactName: contactName,
            phoneNumber: phoneNumber,
            profileImage: profileImage,
            isVideo: isVideo,
            isIncoming: isIncoming,
          ),
        ),
      );
    }
  }

  // Simulate incoming call
  static Future<void> simulateIncomingCall({
    required BuildContext context,
    required String contactName,
    required String phoneNumber,
    String? profileImage,
    bool isVideo = false,
  }) async {
    await startCall(
      context: context,
      contactName: contactName,
      phoneNumber: phoneNumber,
      profileImage: profileImage,
      isVideo: isVideo,
      isIncoming: true,
    );
  }

  // Save call to history
  static Future<void> _saveCallHistory(String phoneNumber, String type, bool isVideo) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_callHistoryKey) ?? '[]';
      final List<dynamic> history = json.decode(historyJson);
      
      final callRecord = {
        'phoneNumber': phoneNumber,
        'type': type, // 'incoming', 'outgoing', 'missed'
        'isVideo': isVideo,
        'timestamp': DateTime.now().toIso8601String(),
        'duration': 0, // Will be updated when call ends
      };
      
      history.insert(0, callRecord);
      
      // Keep only last 100 calls
      if (history.length > 100) {
        history.removeRange(100, history.length);
      }
      
      await prefs.setString(_callHistoryKey, json.encode(history));
    } catch (e) {
      print('Error saving call history: $e');
    }
  }

  // Get call history
  static Future<List<Map<String, dynamic>>> getCallHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_callHistoryKey) ?? '[]';
      final List<dynamic> history = json.decode(historyJson);
      return history.cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error getting call history: $e');
      return [];
    }
  }

  // Clear call history
  static Future<void> clearCallHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_callHistoryKey);
    } catch (e) {
      print('Error clearing call history: $e');
    }
  }

  // Check if app can make calls
  static Future<bool> canMakeCalls() async {
    try {
      final Uri testUri = Uri.parse('tel:');
      return await canLaunchUrl(testUri);
    } catch (e) {
      return false;
    }
  }

  // Request call permissions
  static Future<bool> requestCallPermissions() async {
    final phonePermission = await Permission.phone.request();
    final micPermission = await Permission.microphone.request();
    
    return phonePermission.isGranted && micPermission.isGranted;
  }

  static void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// Call history model
class CallRecord {
  final String phoneNumber;
  final String contactName;
  final String type; // 'incoming', 'outgoing', 'missed'
  final bool isVideo;
  final DateTime timestamp;
  final int duration; // in seconds

  CallRecord({
    required this.phoneNumber,
    required this.contactName,
    required this.type,
    required this.isVideo,
    required this.timestamp,
    required this.duration,
  });

  factory CallRecord.fromJson(Map<String, dynamic> json) {
    return CallRecord(
      phoneNumber: json['phoneNumber'] ?? '',
      contactName: json['contactName'] ?? '',
      type: json['type'] ?? 'outgoing',
      isVideo: json['isVideo'] ?? false,
      timestamp: DateTime.parse(json['timestamp']),
      duration: json['duration'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phoneNumber': phoneNumber,
      'contactName': contactName,
      'type': type,
      'isVideo': isVideo,
      'timestamp': timestamp.toIso8601String(),
      'duration': duration,
    };
  }

  String get formattedDuration {
    if (duration == 0) return '';
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  IconData get callIcon {
    switch (type) {
      case 'incoming':
        return Icons.call_received;
      case 'outgoing':
        return Icons.call_made;
      case 'missed':
        return Icons.call_received;
      default:
        return Icons.call;
    }
  }

  Color get callIconColor {
    switch (type) {
      case 'missed':
        return Colors.red;
      case 'incoming':
        return Colors.green;
      case 'outgoing':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}