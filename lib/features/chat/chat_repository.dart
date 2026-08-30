import 'package:hive_flutter/hive_flutter.dart';
import 'package:messenger/core/services/supabase_service.dart';
import 'package:messenger/models/message_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatRepository {
  final _cache = Hive.box('cache');
  final _queue = Hive.box('offline_queue');

  // Fallback when Supabase not configured — keeps UI working demo mode
  bool get _isLive => SupabaseService.isReady && SupabaseService.isLoggedIn;

  Future<List<Map<String, dynamic>>> fetchConversations() async {
    if (!_isLive) return [];
    try {
      final userId = SupabaseService.currentUser!.id;
      final res = await SupabaseService.client
          .from('conversations')
          .select('*, conversation_participants!inner(user_id)')
          .eq('conversation_participants.user_id', userId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      return [];
    }
  }

  Future<List<Message>> fetchMessages(String conversationId, {int limit = 20, DateTime? before}) async {
    if (!_isLive) return [];
    try {
      // Cursor `before` omitted for MVP simplicity to keep $0 free queries simple
      final res = await SupabaseService.client.from('messages').select().eq('conversation_id', conversationId).order('created_at', ascending: false).limit(limit);
      final uid = SupabaseService.currentUser!.id;
      return List<Map<String, dynamic>>.from(res).map((j) => Message.fromJson(j, currentUserId: uid)).toList().reversed.toList();
    } catch (_) {
      return [];
    }
  }

  Future<Message?> sendMessage({required String conversationId, required String text, String type = 'text', String? mediaUrl, String? replyToId}) async {
    if (!_isLive) return null;
    try {
      final uid = SupabaseService.currentUser!.id;
      final payload = {
        'conversation_id': conversationId,
        'sender_id': uid,
        'type': type,
        'text': text,
        'media_url': mediaUrl,
        'reply_to_id': replyToId,
      };
      final res = await SupabaseService.client.from('messages').insert(payload).select().single();
      return Message.fromJson(res, currentUserId: uid);
    } catch (e) {
      // queue offline
      _queue.add({'conversation_id': conversationId, 'text': text, 'type': type, 'media_url': mediaUrl, 'ts': DateTime.now().toIso8601String()});
      return null;
    }
  }

  RealtimeChannel subscribeMessages(String conversationId, void Function(Message) onNew) {
    final channel = SupabaseService.client.channel('messages:$conversationId')
        .onPostgresChanges(event: PostgresChangeEvent.insert, schema: 'public', table: 'messages', filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'conversation_id', value: conversationId), callback: (payload) {
          final j = payload.newRecord;
          final uid = SupabaseService.currentUser?.id;
          onNew(Message.fromJson(j, currentUserId: uid));
        })
        ..subscribe();
    return channel;
  }

  RealtimeChannel subscribeTyping(String conversationId, void Function(String userId, bool isTyping) onTyping) {
    final channel = SupabaseService.client.channel('conversation:$conversationId')
      ..onBroadcast(event: 'typing', callback: (payload) {
        onTyping(payload['user_id'] as String, payload['is_typing'] as bool);
      })
      ..subscribe();
    return channel;
  }

  Future<void> broadcastTyping(String conversationId, bool isTyping) async {
    if (!_isLive) return;
    final uid = SupabaseService.currentUser!.id;
    final ch = SupabaseService.client.channel('conversation:$conversationId');
    ch.sendBroadcastMessage(event: 'typing', payload: {'user_id': uid, 'is_typing': isTyping});
  }

  Future<List<Map<String, dynamic>>> searchUsers(String q) async {
    if (!_isLive || q.isEmpty) return [];
    try {
      final res = await SupabaseService.client.from('users').select().ilike('name', '%$q%').limit(20);
      return List<Map<String, dynamic>>.from(res);
    } catch (_) { return []; }
  }

  Future<void> updatePresence(bool isOnline) async {
    if (!_isLive) return;
    try {
      final uid = SupabaseService.currentUser!.id;
      await SupabaseService.client.from('users').update({'is_online': isOnline, 'last_seen': DateTime.now().toIso8601String()}).eq('id', uid);
      SupabaseService.client.channel('presence:global').sendBroadcastMessage(event: 'presence', payload: {'user_id': uid, 'is_online': isOnline});
    } catch (_) {}
  }

  Future<void> replayQueue() async {
    if (!_isLive || _queue.isEmpty) return;
    final items = List.from(_queue.values);
    _queue.clear();
    for (var it in items) {
      await sendMessage(conversationId: it['conversation_id'], text: it['text'], type: it['type'], mediaUrl: it['media_url']);
    }
  }
}
