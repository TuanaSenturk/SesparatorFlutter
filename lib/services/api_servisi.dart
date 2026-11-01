import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'api_ayarlari.dart';

/// Ekranda kullanıcıya gösterilecek, anlaşılır hata.
class ApiHatasi implements Exception {
  ApiHatasi(this.mesaj);
  final String mesaj;

  @override
  String toString() => mesaj;
}

/// Bütün servislerin kullandığı ortak istek sınıfı.
/// 2. haftada JWT token'ı buradan tüm isteklere eklenecek.
class ApiServisi {
  final http.Client _istemci = http.Client();

  // async/await: istek bitene kadar uygulamayı dondurmadan bekler.
  // Future: "ileride gelecek bir değer" demek.
  Future<dynamic> get(String yol) async {
    final adres = Uri.parse('${ApiAyarlari.tabanAdres}$yol');

    try {
      final yanit = await _istemci
          .get(adres, headers: {'Accept': 'application/json'})
          .timeout(ApiAyarlari.zamanAsimi);

      if (yanit.statusCode >= 200 && yanit.statusCode < 300) {
        // bodyBytes + utf8: Türkçe karakterler bozulmasın
        return jsonDecode(utf8.decode(yanit.bodyBytes));
      }
      throw ApiHatasi('Sunucu hatası (${yanit.statusCode}).');
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
}