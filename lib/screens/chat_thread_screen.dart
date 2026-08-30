import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:messenger/core/services/storage_service.dart';
import 'package:messenger/core/services/supabase_service.dart';
import 'package:messenger/features/chat/chat_repository.dart';
import 'package:messenger/screens/call_screen.dart';
import 'package:messenger/theme/messenger_theme.dart';

class MessageModel {
  final String id;
  final String text;
  final DateTime time;
  final bool isMine;
  final bool isSeen;
  final bool isTyping;

  const MessageModel({
    required this.id,
    required this.text,
    required this.time,
    required this.isMine,
    this.isSeen = false,
    this.isTyping = false,
  });
}

class ChatThreadScreen extends StatefulWidget {
  final String name;
  final String avatarUrl;
  final bool isActive;
  final String? conversationId;
  final List<MessageModel> initialMessages;

  const ChatThreadScreen({
    super.key,
    required this.name,
    required this.avatarUrl,
    required this.isActive,
    this.conversationId,
    this.initialMessages = const [],
  });

  @override
  State<ChatThreadScreen> createState() => _ChatThreadScreenState();
}

class _ChatThreadScreenState extends State<ChatThreadScreen> {
  late final List<MessageModel> _messages;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showSend = false;
  bool _showTyping = false;
  Timer? _typingDebounce;
  final _chatRepo = ChatRepository();
  String get _convId => widget.conversationId ?? widget.name.hashCode.toString();

  @override
  void initState() {
    super.initState();
    _messages = List.of(widget.initialMessages);
    _controller.addListener(() {
      final hasText = _controller.text.trim().isNotEmpty;
      if (hasText != _showSend) {
        setState(() {
          _showSend = hasText;
        });
      }
      // Typing broadcast debounce 300ms (spec) — free, no DB bloat
      _typingDebounce?.cancel();
      if (SupabaseService.isReady) {
        _chatRepo.broadcastTyping(_convId, hasText);
        _typingDebounce = Timer(const Duration(milliseconds: 800), () => _chatRepo.broadcastTyping(_convId, false));
      }
    });
    // Subscribe typing via Supabase broadcast if configured
    if (SupabaseService.isReady) {
      _chatRepo.subscribeTyping(_convId, (uid, isTyping) {
        if (!mounted || uid == SupabaseService.currentUser?.id) return;
        setState(() => _showTyping = isTyping);
      });
    }
  }

  @override
  void dispose() {
    _typingDebounce?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final local = MessageModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      text: text,
      time: DateTime.now(),
      isMine: true,
      isSeen: false,
    );
    setState(() {
      _messages.add(local);
      _controller.clear();
    });
    _scrollToBottom();
    // Try real send; fallback to mock reply if offline/demo
    final sent = await _chatRepo.sendMessage(conversationId: _convId, text: text);
    if (sent == null && !SupabaseService.isReady) _simulateReply();
  }

  void _simulateReply() {
    _showTyping = true;
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _showTyping = false;
        _messages.add(MessageModel(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          text: '👍',
          time: DateTime.now(),
          isMine: false,
        ));
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final showDateDivider = _shouldShowDateDivider(index);
                return Column(
                  children: [
                    if (showDateDivider)
                      _buildDateDivider(context, message.time),
                    _MessageRow(
                      message: message,
                      avatarUrl: widget.avatarUrl,
                      isActive: widget.isActive,
                    ),
                  ],
                );
              },
            ),
          ),
          if (_showTyping) _buildTypingIndicator(context),
          _buildInputBar(context),
        ],
      ),
    );
  }

  bool _shouldShowDateDivider(int index) {
    if (index == 0) return true;
    final current = _messages[index].time;
    final previous = _messages[index - 1].time;
    return current.year != previous.year ||
        current.month != previous.month ||
        current.day != previous.day;
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      toolbarHeight: 60,
      leadingWidth: 56,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 20,
          color: MessengerTheme.messengerBlue,
        ),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage(widget.avatarUrl),
                backgroundColor: isDark
                    ? MessengerTheme.darkSecondaryBg
                    : MessengerTheme.lightSecondaryBg,
              ),
              if (widget.isActive)
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: MessengerTheme.messengerGreen,
                    border: Border.all(
                      color: isDark
                          ? MessengerTheme.darkBg
                          : MessengerTheme.lightBg,
                      width: 2,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                widget.isActive ? 'Active now' : 'Last seen recently',
                style: TextStyle(
                  fontSize: 11,
                  color: widget.isActive
                      ? MessengerTheme.messengerBlue
                      : (isDark
                          ? const Color(0xFF8A8D91)
                          : MessengerTheme.textSecondary),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CallScreen(name: widget.name, avatarUrl: widget.avatarUrl, isVideo: false, isIncoming: false, conversationId: _convId))),
          icon: const Icon(
            Icons.call_outlined,
            size: 22,
            color: MessengerTheme.messengerBlue,
          ),
        ),
        IconButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CallScreen(name: widget.name, avatarUrl: widget.avatarUrl, isVideo: true, isIncoming: false, conversationId: _convId))),
          icon: const Icon(
            Icons.videocam_outlined,
            size: 24,
            color: MessengerTheme.messengerBlue,
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.info_outline_rounded,
            size: 22,
            color: MessengerTheme.messengerBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildDateDivider(BuildContext context, DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(time.year, time.month, time.day);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    String label;
    if (date == today) {
      label = 'Today';
    } else if (date == today.subtract(const Duration(days: 1))) {
      label = 'Yesterday';
    } else {
      label = DateFormat('MMMM d').format(time);
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: isDark
            ? MessengerTheme.darkSecondaryBg
            : MessengerTheme.lightSecondaryBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isDark
              ? const Color(0xFFB0B3B8)
              : MessengerTheme.textSecondary,
        ),
      ),
    );
  }

  Widget _buildTypingIndicator(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Text(
        '${widget.name} is typing…',
        style: TextStyle(
          fontSize: 12,
          color: isDark
              ? const Color(0xFFB0B3B8)
              : MessengerTheme.textSecondary,
        ),
      ),
    );
  }

  Widget _buildInputBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 12),
      decoration: BoxDecoration(
        color: isDark ? MessengerTheme.darkBg : MessengerTheme.lightBg,
        border: Border(
          top: BorderSide(
            color: isDark
                ? MessengerTheme.darkDividerColor
                : MessengerTheme.dividerColor,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          IconButton(
            onPressed: _showAttachmentSheet,
            icon: const Icon(
              Icons.add_circle_outline_rounded,
              size: 26,
              color: MessengerTheme.messengerBlue,
            ),
          ),
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 40, maxHeight: 100),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDark
                    ? MessengerTheme.darkSecondaryBg
                    : MessengerTheme.lightSecondaryBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: _controller,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                maxLines: null,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 15,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isCollapsed: true,
                  hintText: 'Message',
                  hintStyle: TextStyle(
                    fontSize: 15,
                    color: isDark
                        ? const Color(0xFF8A8D91)
                        : MessengerTheme.textSecondary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          if (_showSend)
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: MessengerTheme.messengerBlue,
                ),
                child: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            )
          else
            IconButton(
              onPressed: _pickImage,
              icon: Icon(
                Icons.camera_alt_outlined,
                size: 26,
                color: isDark
                    ? const Color(0xFFB0B3B8)
                    : MessengerTheme.textSecondary,
              ),
            ),
        ],
      ),
    );
  }

  void _showAttachmentSheet() {
    showModalBottomSheet(context: context, builder: (c) => SafeArea(child: Wrap(children: [
      ListTile(leading: const Icon(Icons.photo, color: MessengerTheme.messengerBlue), title: const Text('Photo'), onTap: () { Navigator.pop(c); _pickImage(); }),
      ListTile(leading: const Icon(Icons.attach_file, color: MessengerTheme.messengerBlue), title: const Text('File'), onTap: () { Navigator.pop(c); _pickFile(); }),
      ListTile(leading: const Icon(Icons.camera_alt, color: MessengerTheme.messengerBlue), title: const Text('Camera'), onTap: () { Navigator.pop(c); _pickImage(source: ImageSource.camera); }),
    ])));
  }

  Future<void> _pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final picker = ImagePicker();
      final x = await picker.pickImage(source: source, imageQuality: 70, maxWidth: 1024);
      if (x == null) return;
      final file = File(x.path);
      if (await file.length() > StorageService.maxImageBytes) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Image too large — compressing to <1MB...')));
      }
      setState(() => _messages.add(MessageModel(id: DateTime.now().microsecondsSinceEpoch.toString(), text: '📷 Photo', time: DateTime.now(), isMine: true)));
      _scrollToBottom();
      final url = await StorageService.uploadMessageMedia(file, _convId);
      if (url != null && SupabaseService.isReady) {
        await _chatRepo.sendMessage(conversationId: _convId, text: '📷 Photo', type: 'image', mediaUrl: url);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Pick failed: $e')));
    }
  }

  Future<void> _pickFile() async {
    try {
      final res = await FilePicker.platform.pickFiles(withData: false);
      if (res == null || res.files.single.path == null) return;
      final file = File(res.files.single.path!);
      if (await file.length() > StorageService.maxVideoBytes) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('File exceeds 10MB limit (free tier)')));
        return;
      }
      setState(() => _messages.add(MessageModel(id: DateTime.now().microsecondsSinceEpoch.toString(), text: '📎 ${res.files.single.name}', time: DateTime.now(), isMine: true)));
      _scrollToBottom();
      final url = await StorageService.uploadMessageMedia(file, _convId, ext: res.files.single.extension ?? 'bin');
      if (url != null && SupabaseService.isReady) await _chatRepo.sendMessage(conversationId: _convId, text: res.files.single.name, type: 'file', mediaUrl: url);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('File pick failed: $e')));
    }
  }
}

class _MessageRow extends StatelessWidget {
  final MessageModel message;
  final String avatarUrl;
  final bool isActive;

  const _MessageRow({
    required this.message,
    required this.avatarUrl,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bubbleColor = message.isMine
        ? MessengerTheme.messengerBlue
        : (isDark
            ? MessengerTheme.darkIncomingBubble
            : MessengerTheme.incomingBubble);
    final textColor = message.isMine
        ? Colors.white
        : (isDark ? Colors.white : Colors.black);
    const radius = Radius.circular(18);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Column(
        crossAxisAlignment: message.isMine
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: message.isMine
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (message.isTyping) ...[
                Container(
                  width: 34,
                  height: 34,
                  margin: const EdgeInsets.only(right: 4),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      for (var i = 0; i < 3; i++)
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: 1),
                          duration: Duration(milliseconds: 600 + i * 200),
                          builder: (context, value, child) {
                            final offset = (value * 4).abs();
                            return Transform.translate(
                              offset: Offset(0, -offset),
                              child: child,
                            );
                          },
                          child: Container(
                            width: 7,
                            height: 7,
                            margin: const EdgeInsets.symmetric(horizontal: 1.5),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDark
                                  ? const Color(0xFF8A8D91)
                                  : MessengerTheme.textSecondary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: BorderRadius.only(
                      topLeft: radius,
                      topRight: radius,
                      bottomLeft: message.isMine ? radius : radius * 0.25,
                      bottomRight: message.isMine ? radius * 0.25 : radius,
                    ),
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.3,
                      color: textColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text(
              '${DateFormat('HH:mm').format(message.time)}${message.isMine && message.isSeen ? ' · Seen' : ''}',
              style: TextStyle(
                fontSize: 11,
                color: isDark
                    ? const Color(0xFF8A8D91)
                    : MessengerTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}