import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:messenger/features/chat/chat_repository.dart';
import 'package:messenger/models/message_model.dart';

final chatRepoProvider = Provider((ref) => ChatRepository());

final conversationsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repo = ref.read(chatRepoProvider);
  return repo.fetchConversations();
});

final messagesProvider = FutureProvider.family<List<Message>, String>((ref, convId) async {
  final repo = ref.read(chatRepoProvider);
  return repo.fetchMessages(convId);
});

final searchUsersProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, query) async {
  if (query.isEmpty) return [];
  final repo = ref.read(chatRepoProvider);
  return repo.searchUsers(query);
});
