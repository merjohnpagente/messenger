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
          // Background gradient or video
          if (widget.isVideo && _webrtcReady)
            Positioned.fill(child: RTCVideoView(_webrtc.remoteRenderer, objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover))
          else
            Container(decoration: BoxDecoration(gradient: isDark ? const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF1C1C1E), Color(0xFF101012)]) : const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFE3F2FF), Color(0xFFBBDEFB)]))),
          // Foreground UI
          SafeArea(child: Column(children: [
            Align(alignment: Alignment.topLeft, child: Padding(padding: const EdgeInsets.all(8), child: IconButton(onPressed: _endCall, icon: Icon(Icons.keyboard_arrow_down_rounded, size: 32, color: widget.isVideo && _webrtcReady ? Colors.white : isDark ? Colors.white : Colors.black87)))),
            const Spacer(),
            if (!(widget.isVideo && _webrtcReady) ) ...[
              CircleAvatar(radius: 60, backgroundImage: NetworkImage(widget.avatarUrl), backgroundColor: Colors.white.withValues(alpha: 0.6)),
              const SizedBox(height: 24),
            ],
            if (widget.isVideo && _webrtcReady)
              Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(12)), child: Text(widget.name, style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600))),
            if (!(widget.isVideo && _webrtcReady))
              Text(widget.name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: widget.isVideo && _webrtcReady ? Colors.white : isDark ? Colors.white : Colors.black87)),
            const SizedBox(height: 8),
            Text(_statusText(), style: TextStyle(fontSize: 16, color: widget.isVideo && _webrtcReady ? Colors.white70 : isDark ? const Color(0xFFB0B3B8) : MessengerTheme.textSecondary)),
            const Spacer(),
            if (_accepted) _buildCallControls(isDark, webrtcOverlay: widget.isVideo && _webrtcReady),
            const Spacer(),
            _buildActionButtons(isDark),
            const SizedBox(height: 24),
            if (SupabaseConfig.turnUrl.contains('openrelay')) Padding(padding: const EdgeInsets.only(bottom:8), child: Text('Free TURN: ${SupabaseConfig.turnUrl} fallback', style: TextStyle(fontSize:10, color: isDark? Colors.white38: Colors.black38))),
          ])),
          // PiP local video draggable
          if (widget.isVideo && _webrtcReady && _cameraOn)
            Positioned(top: 80, right: 16, child: Draggable(child:           Container(width: 110, height: 150, decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white, width:2), boxShadow: const [BoxShadow(color: Colors.black45, blurRadius:8)]), clipBehavior: Clip.hardEdge, child: RTCVideoView(_webrtc.localRenderer, mirror: true, objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover)), feedback: Container(width:110,height:150, decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white, width:2)), clipBehavior: Clip.hardEdge, child: RTCVideoView(_webrtc.localRenderer, mirror:true)), childWhenDragging: const SizedBox())),
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
