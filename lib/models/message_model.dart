enum MessageType { text, image, video, file, audio, system }
enum MessageStatusType { sent, delivered, seen }

class Message {
  final String id;
  final String conversationId;
  final String senderId;
  final MessageType type;
  final String? text;
  final String? mediaUrl;
  final String? replyToId;
  final DateTime createdAt;
  final DateTime? editedAt;
  final DateTime? deletedAt;
  final bool isMine;
  final MessageStatusType? status;

  const Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.type,
    this.text,
    this.mediaUrl,
    this.replyToId,
    required this.createdAt,
    this.editedAt,
    this.deletedAt,
    this.isMine = false,
    this.status,
  });

  factory Message.fromJson(Map<String, dynamic> j, {String? currentUserId}) {
    final sender = j['sender_id'] as String;
    return Message(
      id: j['id'] as String,
      conversationId: j['conversation_id'] as String,
      senderId: sender,
      type: _parseType(j['type'] as String?),
      text: j['text'] as String?,
      mediaUrl: j['media_url'] as String?,
      replyToId: j['reply_to_id'] as String?,
      createdAt: DateTime.parse(j['created_at'] as String),
      editedAt: j['edited_at'] != null ? DateTime.parse(j['edited_at'] as String) : null,
      deletedAt: j['deleted_at'] != null ? DateTime.parse(j['deleted_at'] as String) : null,
      isMine: currentUserId != null && sender == currentUserId,
    );
  }

  static MessageType _parseType(String? s) {
    switch (s) {
      case 'image': return MessageType.image;
      case 'video': return MessageType.video;
      case 'file': return MessageType.file;
      case 'audio': return MessageType.audio;
      case 'system': return MessageType.system;
      default: return MessageType.text;
    }
  }

  bool get isMedia => type == MessageType.image || type == MessageType.video || type == MessageType.file;
}
