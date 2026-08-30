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
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 56,
        title: const Text('Stories'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.search,
              size: 24,
              color: MessengerTheme.messengerBlue,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          const _SectionHeader(title: 'Your stories'),
          const SizedBox(height: 4),
          _buildYourStoryRow(context),
          const SizedBox(height: 8),
          const _SectionHeader(title: 'All stories'),
          const SizedBox(height: 4),
          ..._stories.map((story) => _buildStoryRow(context, story)),
        ],
      ),
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