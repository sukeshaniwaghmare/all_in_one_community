import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase_service.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final SupabaseService _supabaseService = SupabaseService.instance;

  Future<String?> uploadFile(File file, String fileName) async {
    try {
      final bytes = await file.readAsBytes();
      final fileExt = fileName.split('.').last;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uploadPath = 'chat_media/$timestamp.$fileExt';

      await _supabaseService.client.storage
          .from('chat-files')
          .uploadBinary(uploadPath, bytes);

      final publicUrl = _supabaseService.client.storage
          .from('chat-files')
          .getPublicUrl(uploadPath);

      print('File uploaded successfully: $publicUrl');
      return publicUrl;
    } catch (e) {
      print('Upload error: $e');
      return null;
    }
  }
}