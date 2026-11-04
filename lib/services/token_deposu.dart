import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/oturum.dart';

/// Oturumu (token + kullanıcı bilgisi) telefonda şifreli saklar.
/// static: nesne oluşturmadan TokenDeposu.oku() şeklinde çağırılır.
class TokenDeposu {
  static const _depo = FlutterSecureStorage();
  static const _anahtar = 'oturum';

  /// Oturumu JSON metnine çevirip saklar.
  static Future<void> kaydet(Oturum oturum) {
    return _depo.write(key: _anahtar, value: jsonEncode(oturum.toJson()));
  }

  /// Kayıtlı oturumu okur; yoksa null döner.
  static Future<Oturum?> oku() async {
    final metin = await _depo.read(key: _anahtar);
    if (metin == null) return null;

    try {
      return Oturum.fromJson(jsonDecode(metin) as Map<String, dynamic>);
    } catch (_) {
      // Kayıt bozulmuşsa (ör. model değişti) sil ve oturum yokmuş gibi davran
      await sil();
      return null;
    }
  }

  /// Çıkışta oturumu siler.
  static Future<void> sil() => _depo.delete(key: _anahtar);
}