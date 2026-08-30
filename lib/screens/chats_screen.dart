import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:messenger/core/services/supabase_service.dart';
import 'package:messenger/features/chat/chat_repository.dart';
import 'package:messenger/screens/chat_thread_screen.dart';
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

    return Scaffold(
      appBar: _buildAppBar(context, isDark),
      body: Column(
        children: [
          if (!SupabaseService.isReady) Container(height: 24, width: double.infinity, color: const Color(0xFFFF7A00), alignment: Alignment.center, child: const Text('Demo mode — offline Hive queue · add SUPABASE_URL for LIVE', style: TextStyle(color: Colors.white, fontSize:12, fontWeight: FontWeight.w600))),
          MessengerSearchBar(
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
          ),
          Divider(
            height: 1,
            color: isDark
                ? MessengerTheme.darkDividerColor
                : MessengerTheme.dividerColor,
          ),
          _buildStoriesRow(),
          Divider(
            height: 1,
            color: isDark
                ? MessengerTheme.darkDividerColor
                : MessengerTheme.dividerColor,
          ),
          Expanded(
            child: _buildChatsList(filteredConversations),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDark) {
    return AppBar(
      toolbarHeight: 56,
      title: Row(children: [
        const Text('Messenger'),
        if (_liveLoaded) Container(margin: const EdgeInsets.only(left:8), padding: const EdgeInsets.symmetric(horizontal:6, vertical:2), decoration: BoxDecoration(color: MessengerTheme.messengerGreen, borderRadius: BorderRadius.circular(8)), child: const Text('LIVE', style: TextStyle(color: Colors.white, fontSize:10))),
        if (!SupabaseService.isReady) Container(margin: const EdgeInsets.only(left:8), padding: const EdgeInsets.symmetric(horizontal:6, vertical:2), decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(8)), child: const Text('DEMO', style: TextStyle(color: Colors.white, fontSize:10))),
      ]),
      actions: [
        IconButton(
          onPressed: () async {
            if (SupabaseService.isReady) {
              await SupabaseService.client.auth.signOut();
              if (context.mounted) context.go('/login');
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Demo mode — configure Supabase for real logout')));
            }
          },
          icon: const Icon(
            Icons.logout_rounded,
            size: 22,
            color: MessengerTheme.messengerBlue,
          ),
          tooltip: 'Log out',
        ),
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
            Icon(
              Icons.mail_outline_rounded,
              size: 64,
              color: MessengerTheme.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No conversations found',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: MessengerTheme.textSecondary,
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: chats.length,
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