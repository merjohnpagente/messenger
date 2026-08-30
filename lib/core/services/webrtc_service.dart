import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:messenger/core/config/supabase_config.dart';

abstract class WebrtcService {
  RTCVideoRenderer get localRenderer;
  RTCVideoRenderer get remoteRenderer;
  Future<void> init();
  Future<MediaStream> startLocal({bool video = true, bool audio = true});
  Future<RTCPeerConnection> createPeerConnection();
  Future<void> dispose();
  Future<void> toggleMute(bool muted);
  Future<void> toggleCamera(bool enabled);
  Future<void> switchCamera();
  Future<void> setSpeaker(bool speakerOn);
}

class WebrtcP2pImpl implements WebrtcService {
  @override
  final RTCVideoRenderer localRenderer = RTCVideoRenderer();
  @override
  final RTCVideoRenderer remoteRenderer = RTCVideoRenderer();
  MediaStream? _localStream;
  RTCPeerConnection? _pc;

  @override
  Future<void> init() async {
    await localRenderer.initialize();
    await remoteRenderer.initialize();
  }

  @override
  Future<MediaStream> startLocal({bool video = true, bool audio = true}) async {
    final map = {
      'audio': audio,
      'video': video ? {'facingMode': 'user'} : false,
    };
    _localStream = await navigator.mediaDevices.getUserMedia(map);
    localRenderer.srcObject = _localStream;
    return _localStream!;
  }

  @override
  Future<RTCPeerConnection> createPeerConnection() async {
    final config = {
      'iceServers': SupabaseConfig.iceServers,
      'sdpSemantics': 'unified-plan',
    };
    _pc = await createPeerConnectionWithConfig(config);
    if (_localStream != null) {
      for (var track in _localStream!.getTracks()) {
        await _pc!.addTrack(track, _localStream!);
      }
    }
    _pc!.onTrack = (event) {
      if (event.streams.isNotEmpty) {
        remoteRenderer.srcObject = event.streams[0];
      }
    };
    _pc!.onIceCandidate = (candidate) {
      if (kDebugMode) debugPrint('ICE: ${candidate.candidate}');
      // Supabase Realtime broadcast: channel.sendBroadcastMessage(event: 'call:ice', payload: candidate.toMap())
    };
    return _pc!;
  }

  @override
  Future<void> toggleMute(bool muted) async {
    _localStream?.getAudioTracks().forEach((t) => t.enabled = !muted);
  }

  @override
  Future<void> toggleCamera(bool enabled) async {
    _localStream?.getVideoTracks().forEach((t) => t.enabled = enabled);
  }

  @override
  Future<void> switchCamera() async {
    final videoTrack = _localStream?.getVideoTracks().firstOrNull;
    if (videoTrack != null) {
      await Helper.switchCamera(videoTrack);
    }
  }

  @override
  Future<void> setSpeaker(bool speakerOn) async {
    await Helper.setSpeakerphoneOn(speakerOn);
  }

  @override
  Future<void> dispose() async {
    await _localStream?.dispose();
    await _pc?.close();
    await localRenderer.dispose();
    await remoteRenderer.dispose();
  }
}

// Helper extension for older flutter_webrtc
Future<RTCPeerConnection> createPeerConnectionWithConfig(Map<String, dynamic> config) {
  return createPeerConnection(config);
}
