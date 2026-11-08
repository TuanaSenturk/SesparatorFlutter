import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'api_ayarlari.dart';
import 'token_deposu.dart';

/// Ekranda kullanıcıya gösterilecek, anlaşılır hata.
class ApiHatasi implements Exception {
  ApiHatasi(this.mesaj, {this.durumKodu});

  final String mesaj;
  final int? durumKodu; // HTTP durum kodu (401, 403, 500...), bağlantı hatasında null

  bool get yetkisiz => durumKodu == 401;

  @override
  String toString() => mesaj;
}

/// Bütün servislerin kullandığı ortak istek sınıfı.
class ApiServisi {
  final http.Client _istemci = http.Client();

  Future<dynamic> get(String yol) => _gonder('GET', yol);

  Future<dynamic> post(String yol, Map<String, dynamic> govde) => _gonder('POST', yol, govde: govde);

  Future<dynamic> put(String yol, Map<String, dynamic> govde) => _gonder('PUT', yol, govde: govde);

  Future<dynamic> delete(String yol) => _gonder('DELETE', yol);

  /// Her isteğe eklenen başlıklar. Kayıtlı oturum varsa token da eklenir.
  Future<Map<String, String>> _basliklar() async {
    final basliklar = {
      'Accept': 'application/json',
      'Content-Type': 'application/json; charset=utf-8',
    };
    final oturum = await TokenDeposu.oku();
    if (oturum != null) {
      // JWT standardı: Authorization: Bearer <token>
      basliklar['Authorization'] = 'Bearer ${oturum.token}';
    }
    return basliklar;
  }

  Future<dynamic> _gonder(String yontem, String yol, {Map<String, dynamic>? govde}) async {
    final adres = Uri.parse('${ApiAyarlari.tabanAdres}$yol');

    try {
      final basliklar = await _basliklar();
      final govdeMetni = govde == null ? null : jsonEncode(govde); // Map -> JSON metni

      // Yönteme göre doğru isteği seç
      final http.Response yanit = await (switch (yontem) {
        'POST' => _istemci.post(adres, headers: basliklar, body: govdeMetni),
        'PUT' => _istemci.put(adres, headers: basliklar, body: govdeMetni),
        'DELETE' => _istemci.delete(adres, headers: basliklar),
        _ => _istemci.get(adres, headers: basliklar),
      }).timeout(ApiAyarlari.zamanAsimi);

      final metin = utf8.decode(yanit.bodyBytes);

      if (yanit.statusCode >= 200 && yanit.statusCode < 300) {
        return metin.isEmpty ? null : jsonDecode(metin);
      }
      throw ApiHatasi(_hataMesaji(metin, yanit.statusCode), durumKodu: yanit.statusCode);
    } on SocketException {
      throw ApiHatasi('Sunucuya bağlanılamadı. Web API çalışıyor mu?');
    } on TimeoutException {
      throw ApiHatasi('Sunucu yanıt vermedi (zaman aşımı).');
    } on http.ClientException {
      throw ApiHatasi('Sunucuya bağlanılamadı.');
    } on FormatException {
      throw ApiHatasi('Sunucudan beklenmeyen bir yanıt geldi.');
    }
  }

  /// Sunucu {"mesaj": "..."} gönderdiyse onu kullanır (ör. "E-posta veya şifre hatalı."),
  /// göndermediyse durum koduna göre genel bir mesaj üretir.
  String _hataMesaji(String metin, int durumKodu) {
    try {
      final veri = jsonDecode(metin);
      if (veri is Map && veri['mesaj'] is String) return veri['mesaj'] as String;
      // ASP.NET doğrulama hatası: {"errors": {"TakmaAd": ["..."], "Iban": ["..."]}}
      if (veri is Map && veri['errors'] is Map) {
        final mesajlar = (veri['errors'] as Map).values
            .expand((liste) => liste as List)
            .map((m) => m.toString());
        if (mesajlar.isNotEmpty) return mesajlar.join('\n');
      }
    } catch (_) {
      // gövde JSON değilse aşağıdaki genel mesajlara düş
    }
    if (durumKodu == 401) return 'Oturumunuz sona erdi. Lütfen tekrar giriş yapın.';
    if (durumKodu == 403) return 'Bu işlem için yetkiniz yok.';
    return 'Sunucu hatası ($durumKodu).';
  }
}