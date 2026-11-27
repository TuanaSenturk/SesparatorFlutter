import 'package:http_parser/http_parser.dart';

import 'api_ayarlari.dart';
import 'api_servisi.dart';

/// Ses kaydını metne çevirir: POST /api/ses/metne-cevir
class SesServisi {
  final ApiServisi _api = ApiServisi();

  Future<String> metneCevir(String dosyaYolu) async {
    final veri = await _api.dosyaGonder(
      '/api/ses/metne-cevir',
      'ses',
      dosyaYolu,
      MediaType('audio', 'wav'),
      zamanAsimi: ApiAyarlari.asistanZamanAsimi, // sunucu Gemini'yi 30 sn'ye kadar bekleyebilir
    ) as Map<String, dynamic>;
    return veri['metin'] as String;
  }
}
