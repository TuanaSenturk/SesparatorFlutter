import '../models/asistan_yaniti.dart';
import 'api_ayarlari.dart';
import 'api_servisi.dart';

/// Asistan (sohbet) istekleri.
class AsistanServisi {
  final ApiServisi _api = ApiServisi();

  /// POST /api/asistan/mesaj  { "metin": "..." } -> AsistanYaniti
  Future<AsistanYaniti> mesajGonder(String metin) async {
    final veri = await _api.post(
      '/api/asistan/mesaj',
      {'metin': metin.trim()},
      zamanAsimi: ApiAyarlari.asistanZamanAsimi,
    ) as Map<String, dynamic>;
    return AsistanYaniti.fromJson(veri);
  }
}
