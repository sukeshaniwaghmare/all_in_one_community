import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../core/supabase_service.dart';

class CallItem {
  final String id;
  final String name;
  final String phoneNumber;
  final DateTime time;
  final String type; // 'incoming', 'outgoing', 'missed'
  final bool isVideo;
  final String avatar;
  final Color color;

  CallItem({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.time,
    required this.type,
    required this.isVideo,
    required this.avatar,
    required this.color,
  });
}

class CallProvider with ChangeNotifier {
  List<CallItem> _calls = [];

  List<CallItem> get calls => _calls;

  CallProvider() {
    _loadSavedCalls();
    _loadFromDatabase(); // Load from Supabase
  }

  Future<void> _loadSavedCalls() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCalls = prefs.getString('saved_calls');
      if (savedCalls != null) {
        final List<dynamic> callList = jsonDecode(savedCalls);
        _calls = callList.map((c) => CallItem(
          id: c['id'],
          name: c['name'],
          phoneNumber: c['phoneNumber'],
          time: DateTime.parse(c['time']),
          type: c['type'],
          isVideo: c['isVideo'],
          avatar: c['avatar'],
          color: Color(int.parse(c['color'].toString().replaceAll('#', ''), radix: 16)),
        )).toList();
        notifyListeners();
      }
    } catch (e) {
      // Error loading saved calls
    }
  }

  Future<void> _saveCalls() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final callList = _calls.map((c) => {
        'id': c.id,
        'name': c.name,
        'phoneNumber': c.phoneNumber,
        'time': c.time.toIso8601String(),
        'type': c.type,
        'isVideo': c.isVideo,
        'avatar': c.avatar,
        'color': '#${c.color.value.toRadixString(16).padLeft(8, '0')}',
      }).toList();
      await prefs.setString('saved_calls', jsonEncode(callList));
    } catch (e) {
      // Error saving calls
    }
  }

  void addCall(CallItem call) {
    _calls.insert(0, call);
    _saveCalls();
    _saveToDatabase(call); // Save to Supabase
    notifyListeners();
  }

  void makeCall(String name, String phoneNumber, bool isVideo) {
    final call = CallItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      phoneNumber: phoneNumber,
      time: DateTime.now(),
      type: 'outgoing',
      isVideo: isVideo,
      avatar: name.isNotEmpty ? name[0].toUpperCase() : '?',
      color: _getContactColor(name),
    );
    addCall(call);
  }

  // Save call to Supabase database
  Future<void> _saveToDatabase(CallItem call) async {
    try {
      await SupabaseService.instance.insert('calls', {
        'id': call.id,
        'name': call.name,
        'phone_number': call.phoneNumber,
        'time': call.time.toIso8601String(),
        'type': call.type,
        'is_video': call.isVideo,
        'avatar': call.avatar,
        'color': '#${call.color.value.toRadixString(16).padLeft(8, '0')}',
        'user_id': SupabaseService.instance.currentUserId,
      });
    } catch (e) {
      print('Error saving call to database: $e');
    }
  }

  // Load calls from Supabase database
  Future<void> _loadFromDatabase() async {
    try {
      final response = await SupabaseService.instance.client
          .from('calls')
          .select()
          .eq('user_id', SupabaseService.instance.currentUserId ?? '')
          .order('time', ascending: false);
      
      _calls = response.map<CallItem>((data) => CallItem(
        id: data['id'],
        name: data['name'],
        phoneNumber: data['phone_number'],
        time: DateTime.parse(data['time']),
        type: data['type'],
        isVideo: data['is_video'],
        avatar: data['avatar'],
        color: Color(int.parse(data['color'].toString().replaceAll('#', ''), radix: 16)),
      )).toList();
      
      notifyListeners();
    } catch (e) {
      print('Error loading calls from database: $e');
    }
  }

  void clearCallLog() {
    _calls.clear();
    _saveCalls();
    notifyListeners();
  }

  void deleteCall(int index) {
    if (index >= 0 && index < _calls.length) {
      final call = _calls[index];
      _calls.removeAt(index);
      _saveCalls();
      _deleteFromDatabase(call.id); // Delete from Supabase
      notifyListeners();
    }
  }

  // Delete call from Supabase database
  Future<void> _deleteFromDatabase(String callId) async {
    try {
      await SupabaseService.instance.delete('calls', callId);
    } catch (e) {
      print('Error deleting call from database: $e');
    }
  }

  Color _getContactColor(String name) {
    const colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];
    return colors[name.hashCode.abs() % colors.length];
  }
}