import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:messenger/core/services/supabase_service.dart';
import 'package:messenger/features/chat/chat_repository.dart';
import 'package:messenger/screens/chat_thread_screen.dart';
import 'package:messenger/theme/app_tokens.dart';
import 'package:messenger/theme/messenger_theme.dart';
import 'package:messenger/widgets/chat_tile.dart';
import 'package:messenger/widgets/messenger_search_bar.dart';
import 'package:messenger/widgets/story_circle.dart';

class ConversationModel {
  final String id;
  final String name;
  final String avatarUrl;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final bool isActive;

  ConversationModel({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
    required this.isActive,
  });
}

class StoryModel {
  final String id;
  final String name;
  final String avatarUrl;
  final bool isYourStory;
  final bool hasStory;
  final bool isActive;

  const StoryModel({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.isYourStory,
    required this.hasStory,
    required this.isActive,
  });
}

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  late List<ConversationModel> conversations;
  late List<StoryModel> stories;
  String searchQuery = '';
  final _repo = ChatRepository();
  bool _liveLoaded = false;

  @override
  void initState() {
    super.initState();
    _initializeMockData();
    _loadLiveConversations();
  }

  Future<void> _loadLiveConversations() async {
    if (!SupabaseService.isReady) return;
    final live = await _repo.fetchConversations();
    if (live.isNotEmpty && mounted) {
      setState(() {
        // Map Supabase conversations to UI model; keep lastMessage placeholder if empty
        conversations = live.map((c) => ConversationModel(
          id: c['id'] as String,
          name: c['name'] as String? ?? 'Conversation',
          avatarUrl: c['avatar_url'] as String? ?? 'https://api.dicebear.com/7.x/avataaars/svg?seed=${c['id']}',
          lastMessage: 'Tap to open chat (real Supabase)',
          lastMessageTime: DateTime.tryParse(c['created_at'] as String? ?? '') ?? DateTime.now(),
          unreadCount: 0,
          isActive: false,
        )).toList();
        _liveLoaded = true;
      });
    }
  }

  void _initializeMockData() {
    stories = [
      const StoryModel(
        id: '0',
        name: 'Your story',
        avatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=your_story',
        isYourStory: true,
        hasStory: false,
        isActive: false,
      ),
      const StoryModel(
        id: 'story_1',
        name: 'Sarah',
        avatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=sarah',
        isYourStory: false,
        hasStory: true,
        isActive: true,
      ),
      const StoryModel(
        id: 'story_2',
        name: 'Mike',
        avatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=mike',
        isYourStory: false,
        hasStory: true,
        isActive: true,
      ),
      const StoryModel(
        id: 'story_3',
        name: 'Jessica',
        avatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=jessica',
        isYourStory: false,
        hasStory: true,
        isActive: false,
      ),
      const StoryModel(
        id: 'story_4',
        name: 'Alex',
        avatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=alex',
        isYourStory: false,
        hasStory: false,
        isActive: true,
      ),
      const StoryModel(
        id: 'story_5',
        name: 'Emma',
        avatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=emma',
        isYourStory: false,
        hasStory: true,
        isActive: false,
      ),
      const StoryModel(
        id: 'story_6',
        name: 'Chris',
        avatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=chris',
        isYourStory: false,
        hasStory: false,
        isActive: true,
      ),
      const StoryModel(
        id: 'story_7',
        name: 'Lisa',
        avatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=lisa',
        isYourStory: false,
        hasStory: true,
        isActive: false,
      ),
      const StoryModel(
        id: 'story_8',
        name: 'David',
        avatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=david',
        isYourStory: false,
        hasStory: false,
        isActive: true,
      ),
    ];

    conversations = [
      ConversationModel(
        id: '1',
        name: 'Sarah Anderson',
        avatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=sarah',
        lastMessage: 'That sounds amazing! Let me know when you\'re free 😊',
        lastMessageTime: _minutesAgo(5),
        unreadCount: 2,
        isActive: true,
      ),
      ConversationModel(
        id: '2',
        name: 'Design Team',
        avatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=team',
        lastMessage:
            'I\'ve uploaded the final mockups for the new feature. Let me know your feedback',
        lastMessageTime: _hoursAgo(2),
        unreadCount: 1,
        isActive: false,
      ),
      ConversationModel(
        id: '3',
        name: 'Mike Johnson',
        avatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=mike',
        lastMessage: 'You: Can you send me the presentation file?',
        lastMessageTime: _hoursAgo(5),
        unreadCount: 0,
        isActive: true,
      ),
      ConversationModel(
        id: '4',
        name: 'Emily Carter',
        avatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=emily',
        lastMessage: 'You: Thanks for the invite! See you on Friday',
        lastMessageTime: _daysAgo(1),
        unreadCount: 0,
        isActive: false,
      ),
      ConversationModel(
        id: '5',
        name: 'Project Alpha',
        avatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=project',
        lastMessage: 'The sprint planning is set for tomorrow at 10 AM',
        lastMessageTime: _daysAgo(1),
        unreadCount: 0,
        isActive: false,
      ),
      ConversationModel(
        id: '6',
        name: 'Jessica Brown',
        avatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=jessica',
        lastMessage: 'You: Thanks for everything!',
        lastMessageTime: _daysAgo(2),
        unreadCount: 0,
        isActive: true,
      ),
      ConversationModel(
        id: '7',
        name: 'Alex Martinez',
        avatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=alex',
        lastMessage: 'I\'ll catch up with you later',
        lastMessageTime: _daysAgo(3),
        unreadCount: 0,
        isActive: false,
      ),
      ConversationModel(
        id: '8',
        name: 'Travel Group',
        avatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=travel',
        lastMessage: 'Update: Flight bookings are confirmed!',
        lastMessageTime: _daysAgo(4),
        unreadCount: 0,
        isActive: false,
      ),
      ConversationModel(
        id: '9',
        name: 'Chris Lee',
        avatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=chris',
        lastMessage: 'Looking forward to the event!',
        lastMessageTime: _daysAgo(5),
        unreadCount: 0,
        isActive: false,
      ),
      ConversationModel(
        id: '10',
        name: 'Lisa Wong',
        avatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=lisa',
        lastMessage: 'Let\'s connect this week',
        lastMessageTime: _daysAgo(6),
        unreadCount: 0,
        isActive: false,
      ),
    ];
  }

  static DateTime _minutesAgo(int minutes) =>
      DateTime.now().subtract(Duration(minutes: minutes));
  static DateTime _hoursAgo(int hours) =>
      DateTime.now().subtract(Duration(hours: hours));
  static DateTime _daysAgo(int days) =>
      DateTime.now().subtract(Duration(days: days));

  List<ConversationModel> _getFilteredConversations() {
    if (searchQuery.isEmpty) {
      return conversations;
    }
    return conversations
        .where((chat) =>
            chat.name.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filteredConversations = _getFilteredConversations();
    final isWide = MediaQuery.sizeOf(context).width >= 840;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context, isDark),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isWide ? 720 : double.infinity),
          child: Column(
            children: [
              if (!SupabaseService.isReady)
                Container(
                  height: 28,
                  width: double.infinity,
                  decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFFF7A00), Color(0xFFFF9500)])),
                  alignment: Alignment.center,
                  child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.cloud_off_rounded, size: 14, color: Colors.white),
                    SizedBox(width: 6),
                    Text('Demo mode — offline Hive queue · add SUPABASE_URL for LIVE', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.2)),
                  ]),
                ),
              MessengerSearchBar(
                onChanged: (value) => setState(() => searchQuery = value),
              ),
              _buildStoriesSection(isDark),
              Expanded(child: _buildChatsList(filteredConversations)),
            ],
          ),
        ),
      ),
      floatingActionButton: isWide ? null : FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: MessengerTheme.messengerBlue,
        foregroundColor: Colors.white,
        elevation: 2,
        icon: const Icon(Icons.edit_rounded, size: 20),
        label: const Text('New chat', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _buildStoriesSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1E) : Colors.white,
        border: Border(top: BorderSide(color: isDark ? const Color(0xFF232324) : const Color(0xFFF0F2F5)), bottom: BorderSide(color: isDark ? const Color(0xFF232324) : const Color(0xFFF0F2F5))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text('Stories', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.2)),
                const SizedBox(width: 8),
                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: MessengerTheme.messengerBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(999)), child: Text('${stories.length}', style: const TextStyle(color: MessengerTheme.messengerBlue, fontSize: 11, fontWeight: FontWeight.w700))),
                const Spacer(),
                TextButton(onPressed: () {}, child: const Text('See all', style: TextStyle(color: MessengerTheme.messengerBlue, fontWeight: FontWeight.w600, fontSize: 13))),
              ],
            ),
          ),
          const SizedBox(height: 4),
          _buildStoriesRow(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDark) {
    return AppBar(
      toolbarHeight: 64,
      backgroundColor: isDark ? const Color(0xFF1A1A1E) : Colors.white,
      surfaceTintColor: Colors.transparent,
      title: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(11), gradient: AppGradients.primary, boxShadow: const [BoxShadow(color: Color(0x330084FF), blurRadius: 10, offset: Offset(0, 2))]),
            child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text('Chats', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.3)),
              const SizedBox(width: 8),
              if (_liveLoaded)
                Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3), decoration: BoxDecoration(color: MessengerTheme.messengerGreen, borderRadius: BorderRadius.circular(999)), child: Row(mainAxisSize: MainAxisSize.min, children: [Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)), const SizedBox(width: 4), const Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5))])),
              if (!SupabaseService.isReady)
                Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFF9500), Color(0xFFFF7A00)]), borderRadius: BorderRadius.circular(999)), child: const Text('DEMO', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5))),
            ]),
            Text('${_getFilteredConversations().length} conversations', style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 11, color: isDark ? const Color(0xFF8A8D91) : MessengerTheme.textSecondary)),
          ]),
        ],
      ),
      actions: [
        IconButton.filledTonal(
          onPressed: () {},
          icon: const Icon(Icons.videocam_rounded, size: 20),
          style: IconButton.styleFrom(backgroundColor: isDark ? const Color(0xFF232324) : const Color(0xFFF0F2F5), foregroundColor: MessengerTheme.messengerBlue),
          tooltip: 'New call',
        ),
        const SizedBox(width: 4),
        IconButton.filled(
          onPressed: () {},
          icon: const Icon(Icons.edit_rounded, size: 18),
          style: IconButton.styleFrom(backgroundColor: MessengerTheme.messengerBlue, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          tooltip: 'New message',
        ),
        const SizedBox(width: 8),
        PopupMenuButton(
          icon: CircleAvatar(radius: 18, backgroundImage: NetworkImage('https://api.dicebear.com/7.x/avataaars/svg?seed=you'), backgroundColor: isDark ? const Color(0xFF232324) : const Color(0xFFF0F2F5)),
          itemBuilder: (c) => [
            const PopupMenuItem(value: 'profile', child: Row(children: [Icon(Icons.person_outline, size: 18), SizedBox(width: 8), Text('Profile')])),
            const PopupMenuItem(value: 'logout', child: Row(children: [Icon(Icons.logout_rounded, size: 18, color: MessengerTheme.messengerRed), SizedBox(width: 8), Text('Log out', style: TextStyle(color: MessengerTheme.messengerRed))])),
          ],
          onSelected: (v) async {
            if (v == 'logout') {
              if (SupabaseService.isReady) { await SupabaseService.client.auth.signOut(); if (context.mounted) context.go('/login'); } else { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Demo mode — configure Supabase for real logout'))); }
            }
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildStoriesRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        children: List.generate(
          stories.length,
          (index) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: StoryCircle(
              name: stories[index].name,
              avatarUrl: stories[index].avatarUrl,
              isYourStory: stories[index].isYourStory,
              hasStory: stories[index].hasStory,
              isActive: stories[index].isActive,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Opening ${stories[index].name} story'),
                    duration: const Duration(milliseconds: 800),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatsList(List<ConversationModel> chats) {
    if (chats.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF232324) : const Color(0xFFF0F2F5), shape: BoxShape.circle),
              child: Icon(Icons.forum_outlined, size: 42, color: MessengerTheme.textSecondary.withOpacity(0.5)),
            ),
            const SizedBox(height: 16),
            Text('No conversations yet', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text('Start a new chat to see it here', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 16),
            FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.add_rounded, size: 18), label: const Text('New conversation')),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: chats.length,
      separatorBuilder: (_, __) => Divider(height: 1, indent: 78, color: Theme.of(context).dividerColor.withOpacity(0.5)),
      itemBuilder: (context, index) {
        final chat = chats[index];
        return ChatTile(
          name: chat.name,
          avatarUrl: chat.avatarUrl,
          lastMessage: chat.lastMessage,
          lastMessageTime: chat.lastMessageTime,
          unreadCount: chat.unreadCount,
          isActive: chat.isActive,
          onTap: () {
            if (MediaQuery.sizeOf(context).width >= 900) {
              // On wide screens, show as dialog/side sheet for demo — keep push for simplicity
            }
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatThreadScreen(
                  name: chat.name,
                  avatarUrl: chat.avatarUrl,
                  isActive: chat.isActive,
                  conversationId: chat.id,
                  initialMessages: _mockMessagesFor(chat),
                ),
              ),
            );
          },
        );
      },
    );
  }

  List<MessageModel> _mockMessagesFor(ConversationModel chat) {
    final now = DateTime.now();
    return [
      MessageModel(
        id: '${chat.id}_m1',
        text: 'Hey! How are you doing?',
        time: now.subtract(const Duration(hours: 3)),
        isMine: false,
      ),
      MessageModel(
        id: '${chat.id}_m2',
        text: 'I\'m great, thanks! You?',
        time: now.subtract(const Duration(hours: 2, minutes: 58)),
        isMine: true,
        isSeen: true,
      ),
      MessageModel(
        id: '${chat.id}_m3',
        text: 'Just checking in about the weekend plans',
        time: now.subtract(const Duration(hours: 1)),
        isMine: false,
      ),
      MessageModel(
        id: '${chat.id}_m4',
        text: 'Perfect, count me in! 🎉',
        time: now.subtract(const Duration(minutes: 30)),
        isMine: true,
        isSeen: true,
      ),
      MessageModel(
        id: '${chat.id}_m5',
        text: chat.lastMessage,
        time: chat.lastMessageTime,
        isMine: chat.lastMessage.startsWith('You: '),
        isSeen: true,
      ),
    ];
  }
}