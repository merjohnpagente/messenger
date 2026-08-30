class Conversation {
  final String id;
  final bool isGroup;
  final String? name;
  final String? avatarUrl;
  final String? createdBy;
  final DateTime createdAt;
  // Joined fields
  final String? lastMessageText;
  final DateTime? lastMessageAt;
  final int unreadCount;

  const Conversation({
    required this.id,
    required this.isGroup,
    this.name,
    this.avatarUrl,
    this.createdBy,
    required this.createdAt,
    this.lastMessageText,
    this.lastMessageAt,
    this.unreadCount = 0,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) => Conversation(
        id: json['id'] as String,
        isGroup: json['is_group'] as bool? ?? false,
        name: json['name'] as String?,
        avatarUrl: json['avatar_url'] as String?,
        createdBy: json['created_by'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
        lastMessageText: json['last_message_text'] as String?,
        lastMessageAt: json['last_message_at'] != null ? DateTime.parse(json['last_message_at'] as String) : null,
        unreadCount: json['unread_count'] as int? ?? 0,
      );
}

class Participant {
  final String conversationId;
  final String userId;
  final String role;
  final DateTime joinedAt;

  const Participant({required this.conversationId, required this.userId, required this.role, required this.joinedAt});

  factory Participant.fromJson(Map<String, dynamic> j) => Participant(
        conversationId: j['conversation_id'] as String,
        userId: j['user_id'] as String,
        role: j['role'] as String,
        joinedAt: DateTime.parse(j['joined_at'] as String),
      );
}
