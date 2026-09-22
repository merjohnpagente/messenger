import 'package:flutter/material.dart';
import 'package:messenger/core/services/supabase_service.dart';
import 'package:messenger/features/chat/chat_repository.dart';
import 'package:messenger/screens/chat_thread_screen.dart';
import 'package:messenger/theme/messenger_theme.dart';
import 'package:messenger/widgets/messenger_search_bar.dart';

class PersonModel {
  final String id;
  final String name;
  final String avatarUrl;
  final bool isActive;
  final bool hasStory;
  final String? lastSeenText;

  const PersonModel({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.isActive,
    required this.hasStory,
    this.lastSeenText,
  });
}

class PeopleScreen extends StatefulWidget {
  const PeopleScreen({super.key});

  @override
  State<PeopleScreen> createState() => _PeopleScreenState();
}

class _PeopleScreenState extends State<PeopleScreen> {
  int _filterIndex = 0;
  String searchQuery = '';
  final _repo = ChatRepository();
  List<PersonModel> _livePeople = [];
  bool _loadingLive = false;

  static const _filters = ['All', 'Active', 'Stories'];

  @override
  void initState() {
    super.initState();
    _loadLiveUsers();
  }

  Future<void> _loadLiveUsers() async {
    if (!SupabaseService.isReady) return;
    setState(() => _loadingLive = true);
    final users = await _repo.searchUsers('');
    if (users.isNotEmpty && mounted) {
      setState(() {
        _livePeople = users.map((u) => PersonModel(
          id: u['id'] as String,
          name: u['name'] as String? ?? u['email'] as String,
          avatarUrl: u['avatar_url'] as String? ?? 'https://api.dicebear.com/7.x/avataaars/svg?seed=${u['id']}',
          isActive: u['is_online'] as bool? ?? false,
          hasStory: false,
        )).toList();
        _loadingLive = false;
      });
    } else {
      if (mounted) setState(() => _loadingLive = false);
    }
  }

  List<PersonModel> get _sourcePeople => _livePeople.isNotEmpty ? _livePeople : _people;

  static const List<PersonModel> _people = [
    PersonModel(
      id: '1',
      name: 'Sarah Anderson',
      avatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=sarah',
      isActive: true,
      hasStory: true,
    ),
    PersonModel(
      id: '2',
      name: 'Mike Johnson',
      avatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=mike',
      isActive: true,
      hasStory: true,
      lastSeenText: 'Active 5m ago',
    ),
    PersonModel(
      id: '3',
      name: 'Emily Carter',
      avatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=emily',
      isActive: false,
      hasStory: true,
      lastSeenText: 'Last seen 2h ago',
    ),
    PersonModel(
      id: '4',
      name: 'Jessica Brown',
      avatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=jessica',
      isActive: true,
      hasStory: false,
    ),
    PersonModel(
      id: '5',
      name: 'Alex Martinez',
      avatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=alex',
      isActive: true,
      hasStory: false,
    ),
    PersonModel(
      id: '6',
      name: 'Chris Lee',
      avatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=chris',
      isActive: false,
      hasStory: true,
      lastSeenText: 'Last seen yesterday',
    ),
    PersonModel(
      id: '7',
      name: 'Lisa Wong',
      avatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=lisa',
      isActive: false,
      hasStory: true,
      lastSeenText: 'Last seen 3d ago',
    ),
    PersonModel(
      id: '8',
      name: 'David Kim',
      avatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=david',
      isActive: false,
      hasStory: false,
      lastSeenText: 'Last seen 5d ago',
    ),
  ];

  List<PersonModel> _getFilteredPeople() {
    List<PersonModel> result = List.of(_sourcePeople);
    if (_filterIndex == 1) {
      result = result.where((p) => p.isActive).toList();
    } else if (_filterIndex == 2) {
      result = result.where((p) => p.hasStory).toList();
    }
    if (searchQuery.isNotEmpty) {
      result = result
          .where((p) => p.name.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filtered = _getFilteredPeople();
    final w = MediaQuery.sizeOf(context).width;
    final isGrid = w >= 700;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        toolbarHeight: 64,
        backgroundColor: isDark ? const Color(0xFF1A1A1E) : Colors.white,
        title: Row(children: [
          Container(width: 36, height: 36, decoration: BoxDecoration(color: const Color(0xFFEAF3FF), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.people_rounded, color: MessengerTheme.messengerBlue, size: 20)),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('People', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            Text('${filtered.length} contacts • ${filtered.where((p)=>p.isActive).length} online', style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 11)),
          ]),
        ]),
        actions: [
          IconButton.filledTonal(onPressed: () {}, icon: const Icon(Icons.person_add_rounded, size: 18), style: IconButton.styleFrom(backgroundColor: isDark ? const Color(0xFF232324) : const Color(0xFFF0F2F5))),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            children: [
              MessengerSearchBar(onChanged: (v) => setState(()=> searchQuery = v), hintText: 'Search people'),
              _buildFilterRow(),
              Divider(height: 1, color: isDark ? Colors.white10 : const Color(0xFFE8EAED)),
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF232324) : const Color(0xFFF0F2F5),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.search_off_rounded, size: 36, color: MessengerTheme.textSecondary.withOpacity(0.5)),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              searchQuery.isNotEmpty ? 'No results for "$searchQuery"' : 'No people yet',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              searchQuery.isNotEmpty ? 'Try a different name' : 'Invite friends to join Messenger',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      )
                    : isGrid
                        ? GridView.builder(
                            padding: const EdgeInsets.all(12),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 2.8, crossAxisSpacing: 12, mainAxisSpacing: 12),
                            itemCount: filtered.length,
                            itemBuilder: (c,i)=> _buildPersonCard(filtered[i], isDark),
                          )
                        : ListView.separated(
                            itemCount: filtered.length,
                            separatorBuilder: (_, __)=> Divider(height: 1, indent: 72, color: Theme.of(context).dividerColor.withOpacity(0.4)),
                            itemBuilder: (context, index) => _buildPersonTile(filtered[index]),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPersonCard(PersonModel p, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: isDark ? const Color(0xFF1E1E20) : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE8EAED)), boxShadow: isDark ? [] : const [BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0,2))]),
      child: Row(children: [
        _buildAvatar(p, isDark),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(p.name, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Row(children: [Container(width:6,height:6,decoration: BoxDecoration(color: p.isActive? MessengerTheme.messengerGreen: const Color(0xFFB0B3B8), shape: BoxShape.circle)), const SizedBox(width:4), Expanded(child: Text(p.isActive? 'Active now': (p.lastSeenText?? 'Offline'), style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize:11, color: p.isActive? MessengerTheme.messengerGreen: null), maxLines:1))]),
        ])),
        IconButton.filledTonal(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_)=> ChatThreadScreen(name: p.name, avatarUrl: p.avatarUrl, isActive: p.isActive))), icon: const Icon(Icons.chat_bubble_rounded, size:16), style: IconButton.styleFrom(backgroundColor: MessengerTheme.messengerBlue.withOpacity(0.12), foregroundColor: MessengerTheme.messengerBlue)),
      ]),
    );
  }

  Widget _buildFilterRow() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(_filters.length, (index) {
            final sel = index == _filterIndex;
            final icons = [Icons.group_rounded, Icons.bolt_rounded, Icons.auto_awesome_rounded];
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                selected: sel,
                onSelected: (_) => setState(()=> _filterIndex = index),
                label: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icons[index], size: 14, color: sel ? Colors.white : (isDark? Colors.white70: MessengerTheme.textSecondary)), const SizedBox(width:6), Text(_filters[index])]),
                labelStyle: TextStyle(fontSize:13, fontWeight: FontWeight.w600, color: sel ? Colors.white : (isDark? const Color(0xFFB0B3B8): MessengerTheme.textSecondary)),
                backgroundColor: isDark ? const Color(0xFF232324) : Colors.white,
                selectedColor: MessengerTheme.messengerBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999), side: BorderSide(color: sel? MessengerTheme.messengerBlue: (isDark? Colors.white12: const Color(0xFFE4E6EB)))),
                showCheckmark: false,
                padding: const EdgeInsets.symmetric(horizontal:12, vertical:6),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildPersonTile(PersonModel person) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_)=> ChatThreadScreen(name: person.name, avatarUrl: person.avatarUrl, isActive: person.isActive))),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(children: [
            _buildAvatar(person, isDark),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(person.name, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, fontSize: 15), maxLines:1, overflow: TextOverflow.ellipsis),
              const SizedBox(height:2),
              Row(children:[
                Container(width:7,height:7,decoration: BoxDecoration(shape: BoxShape.circle, color: person.isActive? MessengerTheme.messengerGreen: const Color(0xFFB0B3B8))),
                const SizedBox(width:6),
                Expanded(child: Text(person.isActive? 'Active now • Online': (person.lastSeenText?? 'Last seen recently'), style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize:12, color: person.isActive? MessengerTheme.messengerGreen: null), maxLines:1, overflow: TextOverflow.ellipsis)),
              ]),
            ])),
            Container(width:36,height:36,decoration: BoxDecoration(color: isDark? const Color(0xFF232324): const Color(0xFFF0F2F5), shape: BoxShape.circle), child: Icon(Icons.chat_bubble_outline_rounded, size:16, color: isDark? Colors.white70: MessengerTheme.textSecondary)),
          ]),
        ),
      ),
    );
  }

  Widget _buildAvatar(PersonModel person, bool isDark) {
    if (!person.hasStory) {
      return CircleAvatar(
        radius: 26,
        backgroundImage: NetworkImage(person.avatarUrl),
        backgroundColor: isDark
            ? MessengerTheme.darkSecondaryBg
            : MessengerTheme.lightSecondaryBg,
      );
    }
    return Container(
      width: 56,
      height: 56,
      padding: const EdgeInsets.all(2.5),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: MessengerTheme.storyRing,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(2.5),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark ? MessengerTheme.darkBg : MessengerTheme.lightBg,
        ),
        child: CircleAvatar(
          radius: 23,
          backgroundImage: NetworkImage(person.avatarUrl),
          backgroundColor: isDark
              ? MessengerTheme.darkSecondaryBg
              : MessengerTheme.lightSecondaryBg,
        ),
      ),
    );
  }
}