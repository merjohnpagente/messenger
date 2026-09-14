import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:messenger/core/config/supabase_config.dart';
import 'package:messenger/core/services/supabase_service.dart';
import 'package:messenger/core/services/webrtc_service.dart';
import 'package:messenger/theme/messenger_theme.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class CallScreen extends StatefulWidget {
  final String name;
  final String avatarUrl;
  final bool isVideo;
  final bool isIncoming;
  final String? conversationId;

  const CallScreen({
    super.key,
    required this.name,
    required this.avatarUrl,
    required this.isVideo,
    required this.isIncoming,
    this.conversationId,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  Timer? _timer;
  int _seconds = 0;
  bool _accepted = false;
  bool _muted = false;
  bool _speakerOn = true;
  bool _cameraOn = true;
  Timer? _ringTimeout;
  final WebrtcService _webrtc = WebrtcP2pImpl();
  bool _webrtcReady = false;
  bool _permissionDenied = false;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) { try { WakelockPlus.enable(); } catch (_) {} }
    if (!widget.isIncoming) _startTimer();
    _setupRingTimeout();
    if (widget.isVideo) _initWebrtc();
  }

  Future<void> _initWebrtc() async {
    if (kIsWeb) {
      // Web uses browser getUserMedia prompt, no permission_handler
      try {
        await _webrtc.init();
        await _webrtc.startLocal(video: widget.isVideo, audio: true);
        await _webrtc.createPeerConnection();
        if (mounted) setState(() => _webrtcReady = true);
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Web camera/mic blocked: $e')));
        setState(() => _permissionDenied = true);
      }
      return;
    }
    final statuses = await [Permission.camera, Permission.microphone].request();
    if (statuses[Permission.camera] == PermissionStatus.denied || statuses[Permission.microphone] == PermissionStatus.denied) {
      setState(() => _permissionDenied = true);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Camera/mic denied — audio only. Grant in settings.')));
      return;
    }
    try {
      await _webrtc.init();
      await _webrtc.startLocal(video: widget.isVideo, audio: true);
      await _webrtc.createPeerConnection();
      if (mounted) setState(() => _webrtcReady = true);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Video init failed: $e')));
    }
  }

  void _setupRingTimeout() {
    if (widget.isIncoming) {
      _ringTimeout = Timer(const Duration(seconds: 30), () {
        if (!_accepted && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Missed call — 30s timeout (free TURN)')));
          _logCall('missed');
          Navigator.pop(context);
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ringTimeout?.cancel();
    _webrtc.dispose();
    if (!kIsWeb) { try { WakelockPlus.disable(); } catch (_) {} }
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) => setState(() => _seconds++));
  }

  Future<void> _accept() async {
    setState(() => _accepted = true);
    _ringTimeout?.cancel();
    _startTimer();
    // Supabase broadcast: call:accept (free, no TURN cost)
    if (SupabaseService.isReady && widget.conversationId != null) {
      SupabaseService.client.channel('call:${widget.conversationId}').sendBroadcastMessage(event: 'call:accept', payload: {'from': SupabaseService.currentUser?.id, 'is_video': widget.isVideo});
    }
    if (widget.isVideo && !_webrtcReady) await _initWebrtc();
  }

  Future<void> _endCall() async {
    await _logCall(_accepted ? 'ended' : 'missed');
    if (mounted) Navigator.pop(context);
  }

  Future<void> _logCall(String outcome) async {
    if (!SupabaseService.isReady || widget.conversationId == null) {
      // Hive offline log for $0 fallback
      try { Hive.box('cache').put('last_call_${widget.conversationId}', {'name': widget.name, 'isVideo': widget.isVideo, 'duration': _seconds, 'time': DateTime.now().toIso8601String()}); } catch (_) {}
      return;
    }
    try {
      final uid = SupabaseService.currentUser!.id;
      // callee id unknown in mock — use same for demo; replace with real participant lookup in P1
      await SupabaseService.client.from('call_logs').insert({
        'caller_id': widget.isIncoming ? widget.conversationId : uid,
        'callee_id': uid,
        'direction': widget.isIncoming ? 'incoming' : 'outgoing',
        'is_video': widget.isVideo,
        'duration': _seconds,
        'conversation_id': widget.conversationId,
      });
    } catch (_) {}
  }

  String _formatDuration() {
    final m = (_seconds ~/ 60).toString().padLeft(2, '0');
    final s = (_seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String _statusText() {
    if (_permissionDenied && widget.isVideo) return 'Camera denied — audio only';
    if (_accepted) return _formatDuration();
    if (widget.isIncoming) return widget.isVideo ? 'Incoming video call' : 'Incoming audio call';
    return widget.isVideo ? 'Video calling…' : 'Calling…';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Stack(
        children: [
          if (widget.isVideo && _webrtcReady)
            Positioned.fill(child: RTCVideoView(_webrtc.remoteRenderer, objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover))
          else
            Container(decoration: BoxDecoration(gradient: isDark ? const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF0A0A0F), Color(0xFF1A1A1E), Color(0xFF121214)]) : const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFEAF3FF), Color(0xFFD4E8FF), Color(0xFFBBDEFB)]))),
          // subtle vignette
          Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(gradient: RadialGradient(center: Alignment.center, radius: 0.9, colors: [Colors.transparent, Colors.black.withOpacity(isDark ? 0.35 : 0.06)])))),
          SafeArea(child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Row(children: [
                Container(decoration: BoxDecoration(color: Colors.black26, shape: BoxShape.circle), child: IconButton(onPressed: _endCall, icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 28, color: Colors.white))),
                const Spacer(),
                Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(999)), child: Row(children: [Container(width:8,height:8,decoration: BoxDecoration(color: _accepted ? MessengerTheme.messengerGreen : Colors.orange, shape: BoxShape.circle)), const SizedBox(width:6), Text(_statusText(), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700))])),
                const Spacer(),
                Container(decoration: BoxDecoration(color: Colors.black26, shape: BoxShape.circle), child: IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert_rounded, color: Colors.white, size: 20))),
              ]),
            ),
            const Spacer(),
            if (!(widget.isVideo && _webrtcReady)) ...[
              Container(decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3), boxShadow: const [BoxShadow(color: Color(0x40000000), blurRadius: 24, offset: Offset(0, 8))]), child: CircleAvatar(radius: 66, backgroundImage: NetworkImage(widget.avatarUrl), backgroundColor: Colors.white)),
              const SizedBox(height: 20),
              Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(999)), child: Text(widget.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18, letterSpacing: -0.3))),
              const SizedBox(height: 8),
              Text(widget.isIncoming ? 'is calling you…' : 'ringing…', style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 14, fontWeight: FontWeight.w500)),
            ] else ...[
              Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(999)), child: Row(mainAxisSize: MainAxisSize.min, children: [CircleAvatar(radius: 12, backgroundImage: NetworkImage(widget.avatarUrl)), const SizedBox(width: 8), Text(widget.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)), const SizedBox(width: 8), Container(width:6,height:6,decoration: const BoxDecoration(color: MessengerTheme.messengerGreen, shape: BoxShape.circle))])),
            ],
            const Spacer(),
            if (_accepted) _buildCallControls(isDark, webrtcOverlay: true),
            const Spacer(),
            _buildActionButtons(isDark),
            const SizedBox(height: 18),
            if (SupabaseConfig.turnUrl.contains('openrelay')) Padding(padding: const EdgeInsets.only(bottom:8), child: Text('HD • Encrypted • Free TURN fallback', style: TextStyle(fontSize: 10, letterSpacing: 0.4, color: Colors.white.withOpacity(0.55)))),
          ])),
          if (widget.isVideo && _webrtcReady && _cameraOn)
            Positioned(top: 86, right: 14, child: Draggable(feedback: Container(width:116,height:154, decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white, width:2), boxShadow: const [BoxShadow(color: Colors.black45, blurRadius:12)]), clipBehavior: Clip.hardEdge, child: RTCVideoView(_webrtc.localRenderer, mirror:true)), childWhenDragging: const SizedBox(), child: Container(width: 116, height: 154, decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white, width:2), boxShadow: const [BoxShadow(color: Colors.black45, blurRadius:12)]), clipBehavior: Clip.hardEdge, child: Stack(children: [RTCVideoView(_webrtc.localRenderer, mirror: true, objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover), Positioned(bottom:6, right:6, child: Container(padding: const EdgeInsets.all(6), decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle), child: const Icon(Icons.flip_camera_ios_rounded, color: Colors.white, size:14)))])))),
        ],
      ),
    );
  }

  Widget _buildCallControls(bool isDark, {bool webrtcOverlay=false}) {
    final bg = webrtcOverlay ? Colors.black54 : isDark ? const Color(0xFF3A3B3C) : Colors.white.withValues(alpha: 0.85);
    final iconColor = webrtcOverlay ? Colors.white : MessengerTheme.messengerBlue;
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      _ControlButton(icon: _muted ? Icons.mic_off_rounded : Icons.mic_rounded, label: _muted?'Unmute':'Mute', bg: bg, iconColor: iconColor, onTap: () async { setState(()=> _muted=!_muted); await _webrtc.toggleMute(_muted); }),
      const SizedBox(width:24),
      _ControlButton(icon: _speakerOn? Icons.volume_up_rounded: Icons.volume_off_rounded, label: _speakerOn?'Speaker':'Quiet', bg:bg, iconColor:iconColor, onTap: () async { setState(()=> _speakerOn=!_speakerOn); await _webrtc.setSpeaker(_speakerOn); }),
      if (widget.isVideo) ...[ const SizedBox(width:24), _ControlButton(icon: _cameraOn? Icons.videocam_rounded: Icons.videocam_off_rounded, label: _cameraOn?'Camera':'Off', bg:bg, iconColor:iconColor, onTap: () async { setState(()=> _cameraOn=!_cameraOn); await _webrtc.toggleCamera(_cameraOn); }, extra: _cameraOn ? () async => await _webrtc.switchCamera() : null), ],
    ]);
  }

  Widget _buildActionButtons(bool isDark) {
    if (widget.isIncoming && !_accepted) {
      return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        _CircleActionButton(icon: Icons.call_end_rounded, color: MessengerTheme.messengerRed, size:64, onTap: _endCall),
        const SizedBox(width:48),
        _CircleActionButton(icon: widget.isVideo? Icons.videocam_rounded: Icons.call_rounded, color: MessengerTheme.messengerGreen, size:64, onTap: _accept),
      ]);
    }
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      if (!widget.isIncoming && !_accepted) ...[_CircleActionButton(icon: widget.isVideo? Icons.videocam_rounded: Icons.call_rounded, color: MessengerTheme.messengerGreen, size:64, onTap: () => setState(()=> _accepted=true)), const SizedBox(width:48)],
      _CircleActionButton(icon: Icons.call_end_rounded, color: MessengerTheme.messengerRed, size:64, onTap: _endCall),
    ]);
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon; final String label; final VoidCallback onTap; final Color bg; final Color iconColor; final VoidCallback? extra;
  const _ControlButton({required this.icon, required this.label, required this.onTap, required this.bg, required this.iconColor, this.extra});
  @override Widget build(BuildContext context) {
    return GestureDetector(onTap: onTap, onLongPress: extra, child: Column(children: [
      Container(width:48,height:48,decoration: BoxDecoration(shape:BoxShape.circle, color:bg), child: Icon(icon,size:24,color:iconColor)),
      const SizedBox(height:6), Text(label, style: TextStyle(fontSize:12, color: bg==Colors.black54? Colors.white: const Color(0xFFB0B3B8)))
    ]));
  }
}

class _CircleActionButton extends StatelessWidget {
  final IconData icon; final Color color; final double size; final VoidCallback onTap;
  const _CircleActionButton({required this.icon, required this.color, required this.size, required this.onTap});
  @override Widget build(BuildContext context) => GestureDetector(onTap: onTap, child: Container(width:size,height:size,decoration:BoxDecoration(shape:BoxShape.circle,color:color), child: Icon(icon,color:Colors.white,size:size*0.42)));
}
