import 'package:flutter/material.dart';
import 'package:messenger/theme/messenger_theme.dart';
import 'package:messenger/widgets/story_circle.dart';

class StoryEntryModel {
  final String id;
  final String name;
  final String avatarUrl;
  final String timeText;
  final bool isYourStory;
  final bool isActive;

  const StoryEntryModel({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.timeText,
    required this.isYourStory,
    required this.isActive,
  });
}

class StoriesScreen extends StatelessWidget {
  const StoriesScreen({super.key});

  static const List<StoryEntryModel> _stories = [
    StoryEntryModel(
      id: 's1',
      name: 'Sarah',
      avatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=sarah',
      timeText: '5m',
      isYourStory: false,
      isActive: true,
    ),
    StoryEntryModel(
      id: 's2',
      name: 'Mike',
      avatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=mike',
      timeText: '2h',
      isYourStory: false,
      isActive: true,
    ),
    StoryEntryModel(
      id: 's3',
      name: 'Emily',
      avatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=emily',
      timeText: '5h',
      isYourStory: false,
      isActive: false,
    ),
    StoryEntryModel(
      id: 's4',
      name: 'Chris',
      avatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=chris',
      timeText: 'Yesterday',
      isYourStory: false,
      isActive: false,
    ),
    StoryEntryModel(
      id: 's5',
      name: 'Lisa',
      avatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=lisa',
      timeText: 'Yesterday',
      isYourStory: false,
      isActive: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final w = MediaQuery.sizeOf(context).width;
    final isGrid = w >= 650;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        toolbarHeight: 64,
        backgroundColor: isDark ? const Color(0xFF1A1A1E) : Colors.white,
        title: Row(children: [
          Container(width: 36, height: 36, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF00C6FF), Color(0xFF7F00FF)]), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18)),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Stories', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            Text('${_stories.length + 1} stories • Tap to view', style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 11)),
          ]),
        ]),
        actions: [
          IconButton.filledTonal(onPressed: () {}, icon: const Icon(Icons.search_rounded, size: 18), style: IconButton.styleFrom(backgroundColor: isDark ? const Color(0xFF232324) : const Color(0xFFF0F2F5))),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: isGrid
              ? CustomScrollView(slivers: [
                  SliverToBoxAdapter(child: _buildYourStoryCard(context, isDark)),
                  SliverPadding(
                    padding: const EdgeInsets.all(12),
                    sliver: SliverGrid.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.85, crossAxisSpacing: 12, mainAxisSpacing: 12),
                      itemCount: _stories.length,
                      itemBuilder: (c,i)=> _buildStoryCard(context, _stories[i], isDark),
                    ),
                  ),
                ])
              : ListView(padding: const EdgeInsets.symmetric(vertical: 8), children: [
                  const _SectionHeader(title: 'Your stories'),
                  const SizedBox(height: 4),
                  _buildYourStoryRow(context),
                  const SizedBox(height: 8),
                  const _SectionHeader(title: 'All stories'),
                  const SizedBox(height: 4),
                  ..._stories.map((story) => _buildStoryRow(context, story)),
                ]),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(onPressed: () {}, backgroundColor: MessengerTheme.messengerBlue, foregroundColor: Colors.white, icon: const Icon(Icons.add_a_photo_rounded, size: 20), label: const Text('Create', style: TextStyle(fontWeight: FontWeight.w700))),
    );
  }

  Widget _buildYourStoryCard(BuildContext context, bool isDark) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF00C6FF), Color(0xFF0084FF), Color(0xFF7F00FF)]), borderRadius: BorderRadius.circular(20), boxShadow: const [BoxShadow(color: Color(0x330084FF), blurRadius: 16, offset: Offset(0, 4))]),
      child: Row(children: [
        Stack(alignment: Alignment.bottomRight, children: [
          CircleAvatar(radius: 32, backgroundImage: const NetworkImage('https://api.dicebear.com/7.x/avataaars/svg?seed=you'), backgroundColor: Colors.white),
          Container(width: 22, height: 22, decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: MessengerTheme.messengerBlue, width: 2)), child: const Icon(Icons.add_rounded, size: 14, color: MessengerTheme.messengerBlue)),
        ]),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Create story', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 2),
          Text('Share a moment — photo, video or text', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13)),
          const SizedBox(height: 10),
          Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999)), child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.add_rounded, size: 14, color: Color(0xFF0084FF)), SizedBox(width: 4), Text('Add to story', style: TextStyle(color: Color(0xFF0084FF), fontWeight: FontWeight.w700, fontSize: 12))])),
        ])),
      ]),
    );
  }

  Widget _buildStoryCard(BuildContext context, StoryEntryModel s, bool isDark) {
    return Container(
      decoration: BoxDecoration(color: isDark ? const Color(0xFF1E1E20) : Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE8EAED)), boxShadow: isDark ? [] : const [BoxShadow(color: Color(0x0A000000), blurRadius: 12, offset: Offset(0, 4))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child: Stack(children: [
            ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(20)), child: Container(color: isDark ? const Color(0xFF232324) : const Color(0xFFF0F2F5), child: Center(child: CircleAvatar(radius: 36, backgroundImage: NetworkImage(s.avatarUrl))))),
            Positioned(top: 10, left: 10, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(999)), child: Row(mainAxisSize: MainAxisSize.min, children: [Container(width: 6, height: 6, decoration: BoxDecoration(color: s.isActive ? MessengerTheme.messengerGreen : Colors.white54, shape: BoxShape.circle)), const SizedBox(width: 4), Text(s.timeText, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600))] ))),
            Positioned(bottom: 10, right: 10, child: Container(width: 36, height: 36, decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [Color(0xFF0084FF), Color(0xFF0066FF)])), child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20))),
          ]),
        ),
        Padding(padding: const EdgeInsets.all(12), child: Row(children: [
          CircleAvatar(radius: 14, backgroundImage: NetworkImage(s.avatarUrl)),
          const SizedBox(width: 8),
          Expanded(child: Text(s.name, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis)),
          Container(width: 8, height: 8, decoration: BoxDecoration(color: s.isActive ? MessengerTheme.messengerGreen : Colors.transparent, shape: BoxShape.circle)),
        ])),
      ]),
    );
  }

  Widget _buildYourStoryRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          StoryCircle(
            name: 'Your story',
            avatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=you',
            isYourStory: true,
            onTap: () {},
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create story',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Tap to add photos or text',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 13,
                      ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add'),
              style: OutlinedButton.styleFrom(
                foregroundColor: MessengerTheme.messengerBlue,
                side: const BorderSide(color: MessengerTheme.messengerBlue),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryRow(BuildContext context, StoryEntryModel story) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            StoryCircle(
              name: story.name,
              avatarUrl: story.avatarUrl,
              hasStory: true,
              isActive: story.isActive,
              onTap: () {},
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    story.name,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    story.timeText,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 13,
                        ),
                  ),
                ],
              ),
            ),
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: MessengerTheme.messengerBlue,
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: 19,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}