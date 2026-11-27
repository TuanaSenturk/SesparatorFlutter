import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

/// Mikrofon izni ve ses kaydı. Arayüz kararlarını (mesaj, ayarlar ekranı) buton verir.
class SesKaydedici {
  final AudioRecorder _kaydedici = AudioRecorder();

  /// İzin zaten varsa pencere açmadan hemen "granted" döner.
  Future<PermissionStatus> izinIste() => Permission.microphone.request();

  /// WAV, 16 kHz, mono: Gemini'nin kabul ettiği basit bir biçim, saniyesi ~32 KB.
  Future<void> baslat() async {
    final klasor = await getTemporaryDirectory();
    await _kaydedici.start(
      const RecordConfig(encoder: AudioEncoder.wav, sampleRate: 16000, numChannels: 1),
      path: '${klasor.path}/komut.wav',
    );
  }

  /// Kaydı bitirir, dosya yolunu döndürür.
  Future<String?> durdur() => _kaydedici.stop();

  /// Kaydı durdurup dosyayı siler (yanlışlıkla dokunma).
  Future<void> iptal() => _kaydedici.cancel();

  void dispose() => _kaydedici.dispose();
}
