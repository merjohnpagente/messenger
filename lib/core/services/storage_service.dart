import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:messenger/core/services/supabase_service.dart';

/// Web-safe storage service.
/// - Prior WIP used `dart:io File` + `flutter_image_compress` which breaks `flutter build web`.
/// - This version works on all platforms using bytes (IndexedDB on web via Supabase storage).
/// - Picker already compresses via imageQuality:70 / maxWidth:1024; extra native compress is optional
///   and deferred to keep web build green. Size checks enforce spec caps (1MB image / 10MB video).
class StorageService {
  static const maxImageBytes = 1 * 1024 * 1024; // 1MB per spec
  static const maxVideoBytes = 10 * 1024 * 1024; // 10MB per spec

  /// Primary API — upload from raw bytes (web-safe, works on mobile/desktop too).
  static Future<String?> uploadMessageMediaBytes(Uint8List bytes, String conversationId, {String ext = 'jpg'}) async {
    if (!SupabaseService.isReady) return null;
    try {
      if (bytes.length > maxVideoBytes) throw Exception('File exceeds 10MB');
      if (bytes.length > maxImageBytes && ext != 'mp4' && ext != 'mov' && ext != 'webm') {
        // On web we don't have flutter_image_compress; rely on picker compression.
        // If still >1MB, reject gracefully so UI can show snackbar.
        if (kIsWeb) return null;
        // On native, picker already did quality:70 — if still >1MB, reject as well (caller shows snackbar).
        return null;
      }
      final path = 'conv_$conversationId/${DateTime.now().millisecondsSinceEpoch}.$ext';
      await SupabaseService.client.storage.from('message-media').uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );
      return SupabaseService.client.storage.from('message-media').getPublicUrl(path);
    } catch (_) {
      return null;
    }
  }

  /// Backward-compat wrapper for existing callers that previously passed `File`.
  /// Accepts: `File` (dart:io), `XFile` (image_picker), `PlatformFile`, or `Uint8List`.
  /// Avoids `dart:io` import so web build stays green — uses dynamic dispatch.
  static Future<String?> uploadMessageMedia(dynamic file, String conversationId, {String ext = 'jpg'}) async {
    if (!SupabaseService.isReady) return null;
    try {
      Uint8List? bytes;
      if (file is Uint8List) {
        bytes = file;
      } else if (file is List<int>) {
        bytes = Uint8List.fromList(file);
      } else {
        // Try readAsBytes() (File / XFile)
        try {
          final result = await file.readAsBytes() as dynamic;
          if (result is Uint8List) {
            bytes = result;
          } else if (result is List<int>) {
            bytes = Uint8List.fromList(result);
          }
        } catch (_) {
          // Try .bytes (FilePicker PlatformFile withData:true)
          try {
            final b = file.bytes;
            if (b is Uint8List) bytes = b;
            if (b is List<int>) bytes = Uint8List.fromList(b);
          } catch (_) {}
        }
      }
      if (bytes == null) return null;
      return uploadMessageMediaBytes(bytes, conversationId, ext: ext);
    } catch (_) {
      return null;
    }
  }

  /// Legacy helper kept for callers that checked file length before upload.
  /// On web, prefer checking bytes.length directly.
  static Future<Uint8List?> compressIfNeededBytes(Uint8List bytes) async {
    if (bytes.length <= maxImageBytes) return bytes;
    // No-op on web; native would use flutter_image_compress here if needed.
    // Return original so caller can decide to reject >1MB.
    return bytes;
  }
}
