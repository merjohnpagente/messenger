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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
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
                        fontWeight:
                            isUnread ? FontWeight.w700 : FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    if (widget.isActive)
                      Text(
                        'Active now',
                        style: textTheme.bodyMedium?.copyWith(
                          fontSize: 13,
                          color: MessengerTheme.messengerBlue,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    else
                      Text(
                        widget.lastMessage,
                        style: textTheme.bodyMedium?.copyWith(
                          fontSize: 13,
                          color: isUnread
                              ? (isDark ? Colors.white : Colors.black)
                              : (isDark
                                  ? const Color(0xFFB0B3B8)
                                  : MessengerTheme.textSecondary),
                          fontWeight:
                              isUnread ? FontWeight.w600 : FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatTime(widget.lastMessageTime),
                    style: textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      color: isUnread
                          ? MessengerTheme.messengerBlue
                          : (isDark
                              ? const Color(0xFF8A8D91)
                              : MessengerTheme.textSecondary),
                    ),
                  ),
                  const SizedBox(height: 5),
                  if (isUnread)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 1,
                      ),
                      constraints: const BoxConstraints(minWidth: 20),
                      decoration: BoxDecoration(
                        color: MessengerTheme.messengerBlue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${widget.unreadCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  else
                    const SizedBox(height: 18),
                ],
              ),
            ],
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