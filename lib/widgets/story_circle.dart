import 'package:flutter/material.dart';
import 'package:messenger/theme/messenger_theme.dart';

class StoryCircle extends StatelessWidget {
  final String name;
  final String avatarUrl;
  final bool isYourStory;
  final bool hasStory;
  final bool isActive;
  final VoidCallback onTap;

  const StoryCircle({
    super.key,
    required this.name,
    required this.avatarUrl,
    required this.onTap,
    this.isYourStory = false,
    this.hasStory = false,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // Story ring — modern thicker gradient + shadow
              Container(
                width: 68,
                height: 68,
                padding: const EdgeInsets.all(3.2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: hasStory
                      ? const LinearGradient(
                          colors: MessengerTheme.storyRing,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: hasStory
                      ? null
                      : (isDark ? const Color(0xFF2A2A2E) : const Color(0xFFE8EAED)),
                  boxShadow: hasStory
                      ? const [BoxShadow(color: Color(0x330084FF), blurRadius: 10, offset: Offset(0, 2))]
                      : null,
                ),
                child: Container(
                  padding: const EdgeInsets.all(3.5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark ? MessengerTheme.darkBg : Colors.white,
                    boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2))],
                  ),
                  child: CircleAvatar(
                    radius: 26,
                    backgroundImage: NetworkImage(avatarUrl),
                    backgroundColor: isDark ? MessengerTheme.darkSecondaryBg : const Color(0xFFF0F2F5),
                  ),
                ),
              ),
              // Online status indicator
              if (!isYourStory && isActive)
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: MessengerTheme.messengerGreen,
                      border: Border.all(
                        color: isDark
                            ? MessengerTheme.darkBg
                            : MessengerTheme.lightBg,
                        width: 2.5,
                      ),
                    ),
                  ),
                ),
              // Your story plus badge — gradient
              if (isYourStory)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(colors: [Color(0xFF0084FF), Color(0xFF0066FF)]),
                      border: Border.all(color: isDark ? MessengerTheme.darkBg : Colors.white, width: 3),
                      boxShadow: const [BoxShadow(color: Color(0x330084FF), blurRadius: 8, offset: Offset(0, 2))],
                    ),
                    child: const Icon(Icons.add_rounded, color: Colors.white, size: 16),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 72,
            child: Text(
              name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}