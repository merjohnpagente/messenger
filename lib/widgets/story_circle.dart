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
              // Story ring (gradient) or plain grey ring
              Container(
                width: 62,
                height: 62,
                padding: const EdgeInsets.all(3),
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
                      : (isDark
                          ? MessengerTheme.darkDividerColor
                          : MessengerTheme.dividerColor),
                ),
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark
                        ? MessengerTheme.darkBg
                        : MessengerTheme.lightBg,
                  ),
                  child: CircleAvatar(
                    radius: 26,
                    backgroundImage: NetworkImage(avatarUrl),
                    backgroundColor: isDark
                        ? MessengerTheme.darkSecondaryBg
                        : MessengerTheme.lightSecondaryBg,
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
              // Your story plus badge
              if (isYourStory)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: MessengerTheme.messengerBlue,
                      border: Border.all(
                        color: isDark
                            ? MessengerTheme.darkBg
                            : MessengerTheme.lightBg,
                        width: 3,
                      ),
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 16,
                    ),
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