import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:messenger/core/services/supabase_service.dart';

class StorageService {
  static const maxImageBytes = 1 * 1024 * 1024; // 1MB
  static const maxVideoBytes = 10 * 1024 * 1024; // 10MB

  static Future<Uint8List> compressIfNeeded(File file) async {
    final bytes = await file.readAsBytes();
    if (bytes.length <= maxImageBytes) return bytes;
    final compressed = await FlutterImageCompress.compressWithFile(file.absolute.path, quality: 70, minWidth: 1024, minHeight: 1024);
    return compressed ?? bytes;
  }

  static Future<String?> uploadMessageMedia(File file, String conversationId, {String ext = 'jpg'}) async {
    if (!SupabaseService.isReady) return null;
    try {
      final bytes = await compressIfNeeded(file);
      if (bytes.length > maxImageBytes && ext != 'mp4') throw Exception('Image exceeds 1MB after compression');
      if (bytes.length > maxVideoBytes) throw Exception('File exceeds 10MB');
      final path = 'conv_$conversationId/${DateTime.now().millisecondsSinceEpoch}.$ext';
      await SupabaseService.client.storage.from('message-media').uploadBinary(path, bytes, fileOptions: const FileOptions(cacheControl: '3600', upsert: false));
      return SupabaseService.client.storage.from('message-media').getPublicUrl(path);
    } catch (e) {
      return null;
    }
  }
}
