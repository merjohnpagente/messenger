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
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 46,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF232324) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE8EAED)),
          boxShadow: isDark ? [] : [const BoxShadow(color: Color(0x0F000000), blurRadius: 12, offset: Offset(0, 2))],
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isDark ? MessengerTheme.messengerBlue.withOpacity(0.15) : const Color(0xFFEAF3FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.search_rounded, size: 18, color: isDark ? Colors.white70 : MessengerTheme.messengerBlue),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                onChanged: (v) { setState(() {}); widget.onChanged(v); },
                onTap: widget.onSearchTap,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: widget.hintText,
                  hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14, color: isDark ? const Color(0xFF8A8D91) : MessengerTheme.textSecondary),
                  suffixIcon: _controller.text.isNotEmpty
                      ? GestureDetector(
                          onTap: () { _controller.clear(); setState(() {}); widget.onChanged(''); },
                          child: Container(
                            margin: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: isDark ? Colors.white12 : const Color(0xFFF0F2F5), shape: BoxShape.circle),
                            child: Icon(Icons.close_rounded, color: isDark ? Colors.white70 : MessengerTheme.textSecondary, size: 14),
                          ),
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
            if (_controller.text.isEmpty)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: isDark ? Colors.white10 : const Color(0xFFF0F2F5), borderRadius: BorderRadius.circular(999)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.tune_rounded, size: 14, color: isDark ? Colors.white60 : MessengerTheme.textSecondary),
                    const SizedBox(width: 4),
                    Text('Filter', style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 11, fontWeight: FontWeight.w600)),
                  ]),
                ),
              ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}