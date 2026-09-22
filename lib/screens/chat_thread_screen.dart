import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final w = MediaQuery.sizeOf(context).width;
    final isWide = w >= 840;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F10) : const Color(0xFFF8FAFF),
      appBar: _buildAppBar(context),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isWide ? 760 : double.infinity),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF121214) : Colors.white,
                    borderRadius: isWide ? BorderRadius.circular(20) : null,
                    border: isWide ? Border.all(color: isDark ? Colors.white10 : const Color(0xFFE8EAED)) : null,
                  ),
                  margin: EdgeInsets.all(isWide ? 12 : 0),
                  child: ClipRRect(
                    borderRadius: isWide ? BorderRadius.circular(20) : BorderRadius.zero,
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        final showDateDivider = _shouldShowDateDivider(index);
                        return Column(
                          children: [
                            if (showDateDivider) _buildDateDivider(context, message.time),
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
                ),
              ),
              if (_showTyping) _buildTypingIndicator(context),
              _buildInputBar(context),
            ],
          ),
        ),
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
      toolbarHeight: 62,
      backgroundColor: isDark ? const Color(0xFF1A1A1E) : Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leadingWidth: 44,
      leading: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: isDark ? const Color(0xFF232324) : const Color(0xFFF0F2F5), shape: BoxShape.circle),
            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          ),
          padding: EdgeInsets.zero,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      titleSpacing: 8,
      title: Row(
        children: [
          Stack(alignment: Alignment.bottomRight, children: [
            Container(
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: isDark ? const Color(0xFF1A1A1E) : Colors.white, width: 2), boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 2))]),
              child: CircleAvatar(radius: 20, backgroundImage: NetworkImage(widget.avatarUrl), backgroundColor: isDark ? MessengerTheme.darkSecondaryBg : const Color(0xFFF0F2F5)),
            ),
            if (widget.isActive)
              Container(width: 13, height: 13, decoration: BoxDecoration(shape: BoxShape.circle, color: MessengerTheme.messengerGreen, border: Border.all(color: isDark ? const Color(0xFF1A1A1E) : Colors.white, width: 2), boxShadow: const [BoxShadow(color: Color(0x330084FF), blurRadius: 6)])),
          ]),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.name, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
              Row(children: [
                if (widget.isActive) Container(width: 6, height: 6, margin: const EdgeInsets.only(right: 4), decoration: const BoxDecoration(color: MessengerTheme.messengerGreen, shape: BoxShape.circle)),
                Text(widget.isActive ? 'Active now • Online' : 'Last seen recently', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500, color: widget.isActive ? MessengerTheme.messengerGreen : (isDark ? const Color(0xFF8A8D91) : MessengerTheme.textSecondary))),
              ]),
            ]),
          ),
        ],
      ),
      actions: [
        IconButton.filledTonal(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CallScreen(name: widget.name, avatarUrl: widget.avatarUrl, isVideo: false, isIncoming: false, conversationId: _convId))), icon: const Icon(Icons.call_rounded, size: 19), style: IconButton.styleFrom(backgroundColor: isDark ? const Color(0xFF232324) : const Color(0xFFEAF3FF), foregroundColor: MessengerTheme.messengerBlue)),
        IconButton.filledTonal(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CallScreen(name: widget.name, avatarUrl: widget.avatarUrl, isVideo: true, isIncoming: false, conversationId: _convId))), icon: const Icon(Icons.videocam_rounded, size: 19), style: IconButton.styleFrom(backgroundColor: MessengerTheme.messengerBlue, foregroundColor: Colors.white)),
        const SizedBox(width: 4),
        IconButton(onPressed: () {}, icon: Icon(Icons.more_vert_rounded, size: 20, color: isDark ? Colors.white70 : MessengerTheme.textSecondary)),
        const SizedBox(width: 8),
      ],
      bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Divider(height: 1, color: isDark ? Colors.white10 : const Color(0xFFE8EAED))),
    );
  }

  Widget _buildDateDivider(BuildContext context, DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(time.year, time.month, time.day);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    String label;
    if (date == today) label = 'Today';
    else if (date == today.subtract(const Duration(days: 1))) label = 'Yesterday';
    else label = DateFormat('MMMM d, yyyy').format(time);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF232324) : Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE4E6EB)),
        boxShadow: isDark ? [] : const [BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.3, color: isDark ? const Color(0xFFB0B3B8) : MessengerTheme.textSecondary)),
    );
  }

  Widget _buildTypingIndicator(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(color: isDark ? const Color(0xFF232324) : const Color(0xFFF0F2F5), borderRadius: BorderRadius.circular(18)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        SizedBox(width: 36, height: 16, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(3, (i) => AnimatedContainer(duration: Duration(milliseconds: 400 + i * 120), margin: const EdgeInsets.symmetric(horizontal: 2), width: 6, height: 6, decoration: BoxDecoration(color: isDark ? const Color(0xFF8A8D91) : MessengerTheme.textSecondary, shape: BoxShape.circle))))),
        const SizedBox(width: 8),
        Text('${widget.name} is typing…', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isDark ? const Color(0xFFB0B3B8) : MessengerTheme.textSecondary)),
      ]),
    );
  }

  Widget _buildInputBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1E) : Colors.white,
        border: Border(top: BorderSide(color: isDark ? Colors.white10 : const Color(0xFFE8EAED))),
        boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 16, offset: Offset(0, -4))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            decoration: BoxDecoration(color: MessengerTheme.messengerBlue.withOpacity(0.12), shape: BoxShape.circle),
            child: IconButton(onPressed: _showAttachmentSheet, icon: const Icon(Icons.add_rounded, size: 22, color: MessengerTheme.messengerBlue)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 44, maxHeight: 110),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(color: isDark ? const Color(0xFF232324) : const Color(0xFFF0F2F5), borderRadius: BorderRadius.circular(22), border: Border.all(color: isDark ? Colors.white10 : Colors.transparent)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      maxLines: null,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 15, color: isDark ? Colors.white : Colors.black87),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        isCollapsed: true,
                        hintText: 'Message ${widget.name.split(' ').first}…',
                        hintStyle: TextStyle(fontSize: 15, color: isDark ? const Color(0xFF8A8D91) : MessengerTheme.textSecondary),
                      ),
                    ),
                  ),
                  GestureDetector(onTap: () {}, child: Padding(padding: const EdgeInsets.only(left: 8), child: Icon(Icons.emoji_emotions_outlined, size: 22, color: isDark ? const Color(0xFF8A8D91) : MessengerTheme.textSecondary))),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _showSend
                ? GestureDetector(
                    key: const ValueKey('send'),
                    onTap: _sendMessage,
                    child: Container(width: 44, height: 44, decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [Color(0xFF0084FF), Color(0xFF0066FF)])), child: const Icon(Icons.send_rounded, color: Colors.white, size: 20)),
                  )
                : Container(
                    key: const ValueKey('cam'),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: isDark ? const Color(0xFF232324) : const Color(0xFFF0F2F5)),
                    child: IconButton(onPressed: _pickImage, icon: Icon(Icons.camera_alt_rounded, size: 20, color: isDark ? const Color(0xFFB0B3B8) : MessengerTheme.textSecondary)),
                  ),
          ),
        ],
      ),
    );
  }

  void _showAttachmentSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E1E20) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (c) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 36, height: 4, decoration: BoxDecoration(color: isDark ? Colors.white24 : const Color(0xFFE4E6EB), borderRadius: BorderRadius.circular(999))),
              const SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                _sheetBtn(c, Icons.photo_rounded, 'Gallery', const Color(0xFF0084FF), () { Navigator.pop(c); _pickImage(); }),
                _sheetBtn(c, Icons.camera_alt_rounded, 'Camera', const Color(0xFF31A24C), () { Navigator.pop(c); _pickImage(source: ImageSource.camera); }),
                _sheetBtn(c, Icons.attach_file_rounded, 'File', const Color(0xFFFF9500), () { Navigator.pop(c); _pickFile(); }),
                _sheetBtn(c, Icons.location_on_rounded, 'Location', const Color(0xFFE04545), () => Navigator.pop(c)),
              ]),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sheetBtn(BuildContext c, IconData icon, String label, Color color, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Column(children: [
          Container(width: 56, height: 56, decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle), child: Icon(icon, color: color, size: 26)),
          const SizedBox(height: 8),
          Text(label, style: Theme.of(c).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600)),
        ]),
      );

  Future<void> _pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final picker = ImagePicker();
      final x = await picker.pickImage(source: source, imageQuality: 70, maxWidth: 1024);
      if (x == null) return;
      final Uint8List bytes = await x.readAsBytes();
      if (bytes.lengthInBytes > StorageService.maxImageBytes) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(kIsWeb ? 'Image >1MB — pick a smaller image for web' : 'Image too large — compressing to <1MB...')),
          );
          if (kIsWeb) return; // avoid uploading oversize on web where compress not available
        }
      }
      setState(() => _messages.add(MessageModel(id: DateTime.now().microsecondsSinceEpoch.toString(), text: '📷 Photo', time: DateTime.now(), isMine: true)));
      _scrollToBottom();
      final ext = x.name.split('.').last.toLowerCase();
      final safeExt = ['jpg', 'jpeg', 'png', 'webp', 'heic'].contains(ext) ? ext : 'jpg';
      final url = await StorageService.uploadMessageMediaBytes(bytes, _convId, ext: safeExt);
      if (url != null && SupabaseService.isReady) {
        await _chatRepo.sendMessage(conversationId: _convId, text: '📷 Photo', type: 'image', mediaUrl: url);
      } else if (SupabaseService.isReady && bytes.lengthInBytes > StorageService.maxImageBytes) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Image still >1MB after compression — try a smaller photo')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Pick failed: $e')));
    }
  }

  Future<void> _pickFile() async {
    try {
      // withData:true ensures bytes available on web (path is null on web)
      final res = await FilePicker.platform.pickFiles(withData: true);
      if (res == null || res.files.isEmpty) return;
      final picked = res.files.single;
      Uint8List? bytes = picked.bytes;
      // Fallback: if bytes null but path exists (native without withData), try dynamic File read
      if (bytes == null && picked.path != null) {
        // Keep web-safe: attempt dynamic read without importing dart:io statically
        try {
          // ignore: avoid_dynamic_calls
          final dynamic file = picked.path; // placeholder — will fallback to bytes path
          // Actually FilePicker path case without bytes: read via XFile-like dynamic not available
          // So we request withData:true above; if still null, bail.
        } catch (_) {}
      }
      if (bytes == null) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not read file bytes')));
        return;
      }
      if (bytes.lengthInBytes > StorageService.maxVideoBytes) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('File exceeds 10MB limit (free tier)')));
        return;
      }
      setState(() => _messages.add(MessageModel(id: DateTime.now().microsecondsSinceEpoch.toString(), text: '📎 ${picked.name}', time: DateTime.now(), isMine: true)));
      _scrollToBottom();
      final ext = picked.extension ?? 'bin';
      final url = await StorageService.uploadMessageMediaBytes(bytes, _convId, ext: ext);
      if (url != null && SupabaseService.isReady) await _chatRepo.sendMessage(conversationId: _convId, text: picked.name, type: 'file', mediaUrl: url);
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
    const radius = Radius.circular(18);
    final isMine = message.isMine;
    final maxW = MediaQuery.sizeOf(context).width * 0.72;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Column(
        crossAxisAlignment: isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMine) ...[
                CircleAvatar(radius: 14, backgroundImage: NetworkImage(avatarUrl), backgroundColor: isDark ? const Color(0xFF232324) : const Color(0xFFF0F2F5)),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxW),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: isMine ? const LinearGradient(colors: [Color(0xFF0084FF), Color(0xFF0066FF)]) : null,
                      color: isMine ? null : (isDark ? const Color(0xFF2A2A2E) : const Color(0xFFF0F2F5)),
                      borderRadius: BorderRadius.only(topLeft: radius, topRight: radius, bottomLeft: isMine ? radius : const Radius.circular(4), bottomRight: isMine ? const Radius.circular(4) : radius),
                      boxShadow: isMine ? const [BoxShadow(color: Color(0x1A0084FF), blurRadius: 10, offset: Offset(0, 2))] : null,
                    ),
                    child: Text(message.text, style: TextStyle(fontSize: 14.5, height: 1.35, color: isMine ? Colors.white : (isDark ? Colors.white : const Color(0xFF050505)), fontWeight: FontWeight.w400)),
                  ),
                ),
              ),
              if (isMine) const SizedBox(width: 6),
              if (isMine)
                Icon(message.isSeen ? Icons.done_all_rounded : Icons.done_rounded, size: 14, color: message.isSeen ? MessengerTheme.messengerBlue : const Color(0xFFB0B3B8)),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: 4, left: isMine ? 0 : 36, right: isMine ? 22 : 0),
            child: Text('${DateFormat('HH:mm').format(message.time)}${isMine && message.isSeen ? ' · Seen' : ''}', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w500, color: isDark ? const Color(0xFF8A8D91) : const Color(0xFF65676B))),
          ),
        ],
      ),
    );
  }
}