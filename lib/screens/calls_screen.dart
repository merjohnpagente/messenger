import 'package:flutter/material.dart';
import 'package:messenger/theme/messenger_theme.dart';
import 'package:messenger/widgets/messenger_search_bar.dart';

enum CallDirection { incoming, outgoing, missed }

class CallLogModel {
  final String id;
  final String name;
  final String avatarUrl;
  final CallDirection direction;
  final bool isVideo;
  final String timeText;

  const CallLogModel({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.direction,
    required this.isVideo,
    required this.timeText,
  });
}

class CallsScreen extends StatefulWidget {
  const CallsScreen({super.key});

  @override
  State<CallsScreen> createState() => _CallsScreenState();
}

class _CallsScreenState extends State<CallsScreen> {
  String searchQuery = '';

  static const List<CallLogModel> _calls = [
    CallLogModel(
      id: '1',
      name: 'Sarah Anderson',
      avatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=sarah',
      direction: CallDirection.missed,
      isVideo: true,
      timeText: 'Missed · 5m',
    ),
    CallLogModel(
      id: '2',
      name: 'Mike Johnson',
      avatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=mike',
      direction: CallDirection.outgoing,
      isVideo: false,
      timeText: 'Outgoing · 1h',
    ),
    CallLogModel(
      id: '3',
      name: 'Emily Carter',
      avatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=emily',
      direction: CallDirection.incoming,
      isVideo: true,
      timeText: 'Incoming · Yesterday',
    ),
    CallLogModel(
      id: '4',
      name: 'Design Team',
      avatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=team',
      direction: CallDirection.outgoing,
      isVideo: false,
      timeText: 'Outgoing · Yesterday',
    ),
    CallLogModel(
      id: '5',
      name: 'Jessica Brown',
      avatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=jessica',
      direction: CallDirection.missed,
      isVideo: false,
      timeText: 'Missed · 2d',
    ),
    CallLogModel(
      id: '6',
      name: 'Alex Martinez',
      avatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=alex',
      direction: CallDirection.incoming,
      isVideo: true,
      timeText: 'Incoming · 3d',
    ),
    CallLogModel(
      id: '7',
      name: 'Chris Lee',
      avatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=chris',
      direction: CallDirection.outgoing,
      isVideo: false,
      timeText: 'Outgoing · 5d',
    ),
    CallLogModel(
      id: '8',
      name: 'Lisa Wong',
      avatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=lisa',
      direction: CallDirection.incoming,
      isVideo: true,
      timeText: 'Incoming · 1w',
    ),
  ];

  List<CallLogModel> _getFilteredCalls() {
    if (searchQuery.isEmpty) return _calls;
    return _calls
        .where((call) =>
            call.name.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final calls = _getFilteredCalls();

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 56,
        title: const Text('Calls'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.edit_outlined,
              size: 24,
              color: MessengerTheme.messengerBlue,
            ),
            tooltip: 'New message',
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MessengerSearchBar(
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              'Calls you\'ve made',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          Divider(
            height: 1,
            color: isDark
                ? MessengerTheme.darkDividerColor
                : MessengerTheme.dividerColor,
          ),
          Expanded(
            child: calls.isEmpty
                ? Center(
                    child: Text(
                      'No calls found',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  )
                : ListView.builder(
                    itemCount: calls.length,
                    itemBuilder: (context, index) =>
                        _buildCallTile(context, calls[index]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallTile(BuildContext context, CallLogModel call) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMissed = call.direction == CallDirection.missed;

    IconData directionIcon;
    Color directionColor;
    if (call.direction == CallDirection.incoming) {
      directionIcon = Icons.call_received_rounded;
      directionColor = MessengerTheme.messengerGreen;
    } else if (call.direction == CallDirection.outgoing) {
      directionIcon = Icons.call_made_rounded;
      directionColor =
          isDark ? const Color(0xFFB0B3B8) : MessengerTheme.textSecondary;
    } else {
      directionIcon = Icons.call_missed_rounded;
      directionColor = MessengerTheme.messengerRed;
    }

    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundImage: NetworkImage(call.avatarUrl),
              backgroundColor: isDark
                  ? MessengerTheme.darkSecondaryBg
                  : MessengerTheme.lightSecondaryBg,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    call.name,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(
                        directionIcon,
                        size: 13,
                        color: directionColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        call.timeText,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 13,
                              color: isMissed
                                  ? MessengerTheme.messengerRed
                                  : (isDark
                                      ? const Color(0xFFB0B3B8)
                                      : MessengerTheme.textSecondary),
                              fontWeight:
                                  isMissed ? FontWeight.w600 : FontWeight.w400,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _CallButton(isVideo: call.isVideo),
          ],
        ),
      ),
    );
  }
}

class _CallButton extends StatelessWidget {
  final bool isVideo;

  const _CallButton({required this.isVideo});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark
        ? const Color(0xFF3A3B3C)
        : MessengerTheme.lightSecondaryBg;

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bg,
      ),
      child: Icon(
        isVideo ? Icons.videocam_rounded : Icons.call_rounded,
        size: 20,
        color: MessengerTheme.messengerGreen,
      ),
    );
  }
}