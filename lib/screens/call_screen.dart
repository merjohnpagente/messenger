import 'dart:async';
import 'package:flutter/material.dart';
import 'package:messenger/theme/messenger_theme.dart';

class CallScreen extends StatefulWidget {
  final String name;
  final String avatarUrl;
  final bool isVideo;
  final bool isIncoming;

  const CallScreen({
    super.key,
    required this.name,
    required this.avatarUrl,
    required this.isVideo,
    required this.isIncoming,
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

  @override
  void initState() {
    super.initState();
    if (!widget.isIncoming) {
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
      });
    });
  }

  void _accept() {
    setState(() {
      _accepted = true;
    });
    _startTimer();
  }

  void _endCall() {
    Navigator.pop(context);
  }

  String _formatDuration() {
    final minutes = (_seconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String _statusText() {
    if (_accepted) return _formatDuration();
    if (widget.isIncoming) {
      return widget.isVideo
          ? 'Incoming video call'
          : 'Incoming audio call';
    }
    return widget.isVideo ? 'Video calling…' : 'Calling…';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF1C1C1E), Color(0xFF101012)],
                )
              : const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFE3F2FF), Color(0xFFBBDEFB)],
                ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: IconButton(
                    onPressed: _endCall,
                    icon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 32,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(widget.avatarUrl),
                backgroundColor: Colors.white.withValues(alpha: 0.6),
              ),
              const SizedBox(height: 24),
              Text(
                widget.name,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _statusText(),
                style: TextStyle(
                  fontSize: 16,
                  color: isDark
                      ? const Color(0xFFB0B3B8)
                      : MessengerTheme.textSecondary,
                ),
              ),
              const Spacer(),
              if (_accepted) _buildCallControls(isDark),
              const Spacer(),
              _buildActionButtons(isDark),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCallControls(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ControlButton(
          icon: _muted ? Icons.mic_off_rounded : Icons.mic_rounded,
          label: _muted ? 'Unmute' : 'Mute',
          onTap: () {
            setState(() {
              _muted = !_muted;
            });
          },
        ),
        const SizedBox(width: 24),
        _ControlButton(
          icon: _speakerOn ? Icons.volume_up_rounded : Icons.volume_off_rounded,
          label: _speakerOn ? 'Speaker' : 'Quiet',
          onTap: () {
            setState(() {
              _speakerOn = !_speakerOn;
            });
          },
        ),
        if (widget.isVideo) ...[
          const SizedBox(width: 24),
          _ControlButton(
            icon: _cameraOn
                ? Icons.videocam_rounded
                : Icons.videocam_off_rounded,
            label: _cameraOn ? 'Camera' : 'Off',
            onTap: () {
              setState(() {
                _cameraOn = !_cameraOn;
              });
            },
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons(bool isDark) {
    if (widget.isIncoming && !_accepted) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _CircleActionButton(
            icon: Icons.call_end_rounded,
            color: MessengerTheme.messengerRed,
            size: 64,
            onTap: _endCall,
          ),
          const SizedBox(width: 48),
          _CircleActionButton(
            icon: widget.isVideo
                ? Icons.videocam_rounded
                : Icons.call_rounded,
            color: MessengerTheme.messengerGreen,
            size: 64,
            onTap: _accept,
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (!widget.isIncoming && !_accepted) ...[
          _CircleActionButton(
            icon: widget.isVideo
                ? Icons.videocam_rounded
                : Icons.call_rounded,
            color: MessengerTheme.messengerGreen,
            size: 64,
            onTap: () {
              setState(() {
                _accepted = true;
              });
            },
          ),
          const SizedBox(width: 48),
        ],
        _CircleActionButton(
          icon: Icons.call_end_rounded,
          color: MessengerTheme.messengerRed,
          size: 64,
          onTap: _endCall,
        ),
      ],
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? const Color(0xFF3A3B3C)
                  : Colors.white.withValues(alpha: 0.85),
            ),
            child: Icon(icon, size: 24, color: MessengerTheme.messengerBlue),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? const Color(0xFFB0B3B8) : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final VoidCallback onTap;

  const _CircleActionButton({
    required this.icon,
    required this.color,
    required this.size,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: size * 0.42,
        ),
      ),
    );
  }
}