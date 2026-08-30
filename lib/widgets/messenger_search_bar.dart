import 'package:flutter/material.dart';
import 'package:messenger/theme/messenger_theme.dart';

class MessengerSearchBar extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final VoidCallback? onSearchTap;
  final String hintText;

  const MessengerSearchBar({
    super.key,
    required this.onChanged,
    this.onSearchTap,
    this.hintText = 'Search Messenger',
  });

  @override
  State<MessengerSearchBar> createState() => _MessengerSearchBarState();
}

class _MessengerSearchBarState extends State<MessengerSearchBar> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      child: Container(
        height: 38,
        decoration: BoxDecoration(
          color: isDark
              ? MessengerTheme.darkSecondaryBg
              : MessengerTheme.lightSecondaryBg,
          borderRadius: BorderRadius.circular(19),
        ),
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,
          onChanged: widget.onChanged,
          onTap: widget.onSearchTap,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: widget.hintText,
            hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  color: isDark
                      ? const Color(0xFF8A8D91)
                      : MessengerTheme.textSecondary,
                ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 8, right: 4),
              child: Icon(
                Icons.search,
                size: 18,
                color: isDark
                    ? const Color(0xFF8A8D91)
                    : MessengerTheme.textSecondary,
              ),
            ),
            suffixIcon: _controller.text.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      _controller.clear();
                      widget.onChanged('');
                    },
                    child: Icon(
                      Icons.close,
                      color: isDark
                          ? const Color(0xFF8A8D91)
                          : MessengerTheme.textSecondary,
                      size: 18,
                    ),
                  )
                : null,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
          ),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14),
        ),
      ),
    );
  }
}