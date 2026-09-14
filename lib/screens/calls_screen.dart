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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        toolbarHeight: 64,
        backgroundColor: isDark ? const Color(0xFF1A1A1E) : Colors.white,
        title: Row(children: [
          Container(width: 36, height: 36, decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.call_rounded, color: MessengerTheme.messengerGreen, size: 18)),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Calls', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            Text('${calls.length} recent • HD quality', style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 11)),
          ]),
        ]),
        actions: [
          IconButton.filledTonal(onPressed: () {}, icon: const Icon(Icons.videocam_rounded, size: 18), style: IconButton.styleFrom(backgroundColor: MessengerTheme.messengerBlue, foregroundColor: Colors.white)),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            MessengerSearchBar(onChanged: (v) => setState(()=> searchQuery = v), hintText: 'Search calls'),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
              child: Row(children: [
                Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF0084FF), Color(0xFF0066FF)]), borderRadius: BorderRadius.circular(999)), child: const Row(children: [Icon(Icons.history_rounded, size: 14, color: Colors.white), SizedBox(width: 4), Text('Recent', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700))])),
                const SizedBox(width: 8),
                Chip(label: const Text('Missed'), backgroundColor: isDark ? const Color(0xFF232324) : Colors.white, side: BorderSide(color: isDark ? Colors.white12 : const Color(0xFFE4E6EB)), labelStyle: Theme.of(context).textTheme.labelSmall),
              ]),
            ),
            Divider(height: 1, color: isDark ? Colors.white10 : const Color(0xFFE8EAED)),
            Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 8), child: Text('Recent calls', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.2))),
            Expanded(
              child: calls.isEmpty
                  ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.call_outlined, size: 48, color: MessengerTheme.textSecondary.withOpacity(0.4)), const SizedBox(height: 12), Text('No calls found', style: Theme.of(context).textTheme.bodyMedium)]))
                  : ListView.separated(
                      itemCount: calls.length,
                      separatorBuilder: (_, __) => Divider(height: 1, indent: 72, color: Theme.of(context).dividerColor.withOpacity(0.35)),
                      itemBuilder: (context, index) => _buildCallTile(context, calls[index]),
                    ),
            ),
          ]),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(onPressed: () {}, backgroundColor: MessengerTheme.messengerGreen, foregroundColor: Colors.white, icon: const Icon(Icons.add_call, size: 20), label: const Text('New call', style: TextStyle(fontWeight: FontWeight.w700))),
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
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(shape: BoxShape.circle, gradient: isVideo ? const LinearGradient(colors: [Color(0xFF0084FF), Color(0xFF0066FF)]) : const LinearGradient(colors: [Color(0xFF31A24C), Color(0xFF248A3D)]), boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, 2))]),
      child: Icon(isVideo ? Icons.videocam_rounded : Icons.call_rounded, size: 18, color: Colors.white),
    );
  }
}