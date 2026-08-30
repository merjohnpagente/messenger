enum CallDirection { incoming, outgoing, missed }

class CallLog {
  final String id;
  final String? conversationId;
  final String callerId;
  final String calleeId;
  final CallDirection direction;
  final bool isVideo;
  final int duration;
  final DateTime startedAt;
  final DateTime? endedAt;

  const CallLog({
    required this.id,
    this.conversationId,
    required this.callerId,
    required this.calleeId,
    required this.direction,
    required this.isVideo,
    required this.duration,
    required this.startedAt,
    this.endedAt,
  });

  factory CallLog.fromJson(Map<String, dynamic> j) => CallLog(
        id: j['id'] as String,
        conversationId: j['conversation_id'] as String?,
        callerId: j['caller_id'] as String,
        calleeId: j['callee_id'] as String,
        direction: _dir(j['direction'] as String),
        isVideo: j['is_video'] as bool? ?? false,
        duration: j['duration'] as int? ?? 0,
        startedAt: DateTime.parse(j['started_at'] as String),
        endedAt: j['ended_at'] != null ? DateTime.parse(j['ended_at'] as String) : null,
      );

  static CallDirection _dir(String s) {
    switch (s) {
      case 'incoming': return CallDirection.incoming;
      case 'outgoing': return CallDirection.outgoing;
      default: return CallDirection.missed;
    }
  }
}
