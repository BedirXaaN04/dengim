import 'dart:async';
import 'dart:io';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import '../utils/log_service.dart';
import 'cloudinary_service.dart';

/// Ses kaydı servisi - Mikrofon erişimi ve kayıt yönetimi
class AudioRecorderService {
  final AudioRecorder _recorder = AudioRecorder();
  String? _currentRecordingPath;
  bool _isRecording = false;
  Timer? _durationTimer;
  int _recordingDurationSeconds = 0;
  
  // Callbacks for UI updates
  Function(int duration)? onDurationUpdate;
  Function(double amplitude)? onAmplitudeUpdate;

  bool get isRecording => _isRecording;
  int get recordingDuration => _recordingDurationSeconds;

  /// Mikrofon izni kontrolü
  Future<bool> hasPermission() async {
    return await _recorder.hasPermission();
  }

  /// Kayıt başlat
  Future<bool> startRecording() async {
    try {
      // İzin kontrolü
      if (!await hasPermission()) {
        LogService.w("Mikrofon izni verilmedi");
        return false;
      }

      // Kayıt dosya yolunu oluştur
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _currentRecordingPath = '${directory.path}/voice_message_$timestamp.m4a';

      // Kayıt konfigürasyonu
      const config = RecordConfig(
        encoder: AudioEncoder.aacLc, // iOS ve Android uyumlu
        bitRate: 128000,
        sampleRate: 44100,
      );

      await _recorder.start(config, path: _currentRecordingPath!);
      
      _isRecording = true;
      _recordingDurationSeconds = 0;

      // Süre takibi için timer
      _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _recordingDurationSeconds++;
        onDurationUpdate?.call(_recordingDurationSeconds);
      });

      // Amplitude takibi (ses seviyesi göstergesi için)
      _startAmplitudeMonitoring();

      LogService.i("Ses kaydı başladı: $_currentRecordingPath");
      return true;
    } catch (e) {
      LogService.e("Ses kaydı başlatılamadı", e);
      return false;
    }
  }

  /// Amplitude monitoring for visual feedback
  void _startAmplitudeMonitoring() async {
    while (_isRecording) {
      try {
        final amplitude = await _recorder.getAmplitude();
        onAmplitudeUpdate?.call(amplitude.current);
      } catch (e) {
        // Ignore amplitude errors
      }
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  /// Kayıt durdur ve dosya yolunu döndür
  Future<String?> stopRecording() async {
    try {
      _durationTimer?.cancel();
      _durationTimer = null;
      _isRecording = false;

      final path = await _recorder.stop();
      LogService.i("Ses kaydı durduruldu: $path (${_recordingDurationSeconds}s)");
      
      return path;
    } catch (e) {
      LogService.e("Ses kaydı durdurulamadı", e);
      return null;
    }
  }

  /// Kayıt iptal et
  Future<void> cancelRecording() async {
    try {
      _durationTimer?.cancel();
      _durationTimer = null;
      _isRecording = false;
      _recordingDurationSeconds = 0;

      await _recorder.stop();
      
      // Dosyayı sil
      if (_currentRecordingPath != null) {
        final file = File(_currentRecordingPath!);
        if (await file.exists()) {
          await file.delete();
        }
      }
      
      LogService.i("Ses kaydı iptal edildi");
    } catch (e) {
      LogService.e("Ses kaydı iptal edilemedi", e);
    }
  }

  /// Ses dosyasını Cloudinary'ye yükle ve URL döndür
  Future<String?> uploadRecording(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        LogService.w("Ses dosyası bulunamadı: $filePath");
        return null;
      }

      // Cloudinary'ye yükle (ses dosyası için)
      final bytes = await file.readAsBytes();
      final url = await CloudinaryService.uploadAudioBytes(bytes);
      
      // Yükleme başarılıysa geçici dosyayı sil
      if (url != null) {
        await file.delete();
      }
      
      return url;
    } catch (e) {
      LogService.e("Ses dosyası yüklenemedi", e);
      return null;
    }
  }

  /// Kayıt süresini formatla (mm:ss)
  static String formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void dispose() {
    _durationTimer?.cancel();
    _recorder.dispose();
  }
}
