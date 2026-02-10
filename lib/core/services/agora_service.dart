import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/log_service.dart';

class AgoraService {
  static final AgoraService _instance = AgoraService._internal();
  factory AgoraService() => _instance;
  AgoraService._internal();

  // Senin verdiğin Agora App ID
  static const String appId = "7b8bc94f1593413b8dfd81f4d0d0b464";

  RtcEngine? _engine;
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      // Mikrofon ve Kamera izinlerini kontrol et
      await [Permission.microphone, Permission.camera].request();

      _engine = createAgoraRtcEngine();
      await _engine!.initialize(const RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ));

      _isInitialized = true;
      LogService.i("Agora SDK initialized successfully.");
    } catch (e) {
      LogService.e("Agora SDK initialization failed", e);
    }
  }

  // Kanala katıl (Sesli veya Görüntülü)
  Future<void> joinChannel({
    required String channelId,
    required int uid,
    bool isVideo = false,
    bool isHost = true,
  }) async {
    if (_engine == null) await init();

    await _engine!.setChannelProfile(
      isHost ? ChannelProfileType.channelProfileLiveBroadcasting : ChannelProfileType.channelProfileCommunication
    );

    if (isHost) {
      await _engine!.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    }

    if (isVideo) {
      await _engine!.enableVideo();
      await _engine!.startPreview();
    } else {
      await _engine!.enableAudio();
    }

    await _engine!.joinChannel(
      token: "", // Token mantığı eklenecek (Test için boş bırakılabilir)
      channelId: channelId,
      uid: uid,
      options: const ChannelMediaOptions(),
    );
    
    LogService.i("Joined Agora Channel: $channelId");
  }

  Future<void> leaveChannel() async {
    if (_engine != null) {
      await _engine!.leaveChannel();
      LogService.i("Left Agora Channel.");
    }
  }

  RtcEngine get engine {
    if (_engine == null) throw Exception("Agora Engine not initialized");
    return _engine!;
  }
}
