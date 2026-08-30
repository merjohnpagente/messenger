import 'package:flutter/material.dart';
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

  static const _filters = ['All', 'Active', 'Stories'];

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
    List<PersonModel> result = List.of(_people);
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

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 56,
        title: const Text('People'),
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
        children: [
          MessengerSearchBar(
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
          ),
          _buildFilterRow(),
          Divider(
            height: 1,
            color: isDark
                ? MessengerTheme.darkDividerColor
                : MessengerTheme.dividerColor,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) => _buildPersonTile(filtered[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 12),
      child: Row(
        children: List.generate(_filters.length, (index) {
          final selected = index == _filterIndex;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _filterIndex = index;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                decoration: BoxDecoration(
                  color: selected
                      ? MessengerTheme.messengerBlue
                      : (isDark
                          ? MessengerTheme.darkSecondaryBg
                          : MessengerTheme.lightSecondaryBg),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _filters[index],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: selected
                        ? Colors.white
                        : (isDark
                            ? const Color(0xFFB0B3B8)
                            : MessengerTheme.textSecondary),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPersonTile(PersonModel person) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatThreadScreen(
              name: person.name,
              avatarUrl: person.avatarUrl,
              isActive: person.isActive,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        child: Row(
          children: [
            _buildAvatar(person, isDark),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    person.name,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    person.isActive
                        ? 'Active now'
                        : (person.lastSeenText ?? 'Last seen recently'),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 13,
                          color: person.isActive
                              ? MessengerTheme.messengerBlue
                              : (isDark
                                  ? const Color(0xFFB0B3B8)
                                  : MessengerTheme.textSecondary),
                          fontWeight: FontWeight.w400,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.edit_outlined,
                size: 20,
                color: isDark
                    ? const Color(0xFF8A8D91)
                    : MessengerTheme.textSecondary,
              ),
            ),
          ],
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