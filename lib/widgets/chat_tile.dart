import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:messenger/theme/messenger_theme.dart';

class ChatTile extends StatefulWidget {
  final String name;
  final String avatarUrl;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final bool isActive;
  final VoidCallback onTap;

  const ChatTile({
    super.key,
    required this.name,
    required this.avatarUrl,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.onTap,
    this.unreadCount = 0,
    this.isActive = false,
  });

  @override
  State<ChatTile> createState() => _ChatTileState();
}

class _ChatTileState extends State<ChatTile> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;
    final isUnread = widget.unreadCount > 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isUnread ? (isDark ? const Color(0xFF232324) : const Color(0xFFF0F7FF)) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              children: [
                _buildAvatar(isDark),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.name,
                        style: textTheme.bodyLarge?.copyWith(
                          fontSize: 15,
                          fontWeight: isUnread ? FontWeight.w700 : FontWeight.w600,
                          letterSpacing: -0.2,
                          color: isDark ? Colors.white : const Color(0xFF050505),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          if (widget.isActive)
                            Container(
                              width: 6,
                              height: 6,
                              margin: const EdgeInsets.only(right: 6),
                              decoration: const BoxDecoration(shape: BoxShape.circle, color: MessengerTheme.messengerBlue),
                            ),
                          Expanded(
                            child: Text(
                              widget.isActive ? 'Active now • ${widget.lastMessage}' : widget.lastMessage,
                              style: textTheme.bodyMedium?.copyWith(
                                fontSize: 13,
                                height: 1.2,
                                color: widget.isActive
                                    ? MessengerTheme.messengerBlue
                                    : isUnread
                                        ? (isDark ? Colors.white : Colors.black87)
                                        : (isDark ? const Color(0xFFB0B3B8) : MessengerTheme.textSecondary),
                                fontWeight: isUnread ? FontWeight.w600 : FontWeight.w400,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isUnread ? MessengerTheme.messengerBlue : (isDark ? const Color(0xFF2A2A2E) : const Color(0xFFF0F2F5)),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        _formatTime(widget.lastMessageTime),
                        style: textTheme.labelSmall?.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isUnread ? Colors.white : (isDark ? const Color(0xFFB0B3B8) : MessengerTheme.textSecondary),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (isUnread)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF0084FF), Color(0xFF0066FF)]),
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: const [BoxShadow(color: Color(0x330084FF), blurRadius: 8, offset: Offset(0, 2))],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${widget.unreadCount}',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
                        ),
                      )
                    else
                      Icon(Icons.check_circle_outline_rounded, size: 14, color: isDark ? const Color(0xFF3A3B3C) : const Color(0xFFE4E6EB)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(bool isDark) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: 28,
          backgroundImage: NetworkImage(widget.avatarUrl),
          backgroundColor:
              isDark ? MessengerTheme.darkSecondaryBg : MessengerTheme.lightSecondaryBg,
        ),
        if (widget.isActive)
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: MessengerTheme.messengerGreen,
              border: Border.all(
                color: isDark ? MessengerTheme.darkBg : MessengerTheme.lightBg,
                width: 2,
              ),
            ),
          ),
      ],
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      return DateFormat('HH:mm').format(dateTime);
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else if (now.difference(dateTime).inDays < 7) {
      return DateFormat('E').format(dateTime);
    } else {
      return DateFormat('MMM d').format(dateTime);
    }
  }
}