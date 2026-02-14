import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../domain/entities/call.dart';
import '../provider/call_provider.dart';
import '../presentation/call_screen.dart';
import '../presentation/incoming_call_dialog.dart';

class CallService {
  static String? _currentDialogCallId;
  
  static void initializeCallListener(BuildContext context) {
    print('🔔 Initializing call listener');
    final callProvider = context.read<CallProvider>();
    callProvider.startListeningForIncomingCalls();
    
    callProvider.addListener(() {
      final call = callProvider.currentCall;
      print('🔔 Call provider listener triggered. Call: ${call?.id}, Status: ${call?.status}');
      if (call != null && call.status == CallStatus.ringing && _currentDialogCallId != call.id) {
        print('📣 Showing incoming call dialog');
        _currentDialogCallId = call.id;
        _showIncomingCallDialog(context, call);
      }
    });
  }

  static Future<void> makeCall(
    BuildContext context, 
    String receiverId, 
    CallType callType,
  ) async {
    try {
      if (receiverId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot make call: Invalid receiver ID')),
        );
        return;
      }

      final callProvider = context.read<CallProvider>();
      await callProvider.initiateCall(receiverId, callType);
      
      if (callProvider.currentCall != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CallScreen(call: callProvider.currentCall!),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to initiate call')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Call error: $e')),
      );
    }
  }

  static void _showIncomingCallDialog(BuildContext context, Call call) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => IncomingCallDialog(call: call),
    ).then((_) {
      _currentDialogCallId = null;
    });
  }
}