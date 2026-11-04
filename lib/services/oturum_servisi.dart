import '../models/oturum.dart';
import 'api_servisi.dart';
import 'token_deposu.dart';

/// Giriş, çıkış ve kayıtlı oturum işlemleri.
class OturumServisi {
  final ApiServisi _api = ApiServisi();

  /// POST /api/oturum/giris -> başarılıysa oturumu kaydeder ve döndürür.
  /// Hatalıysa ApiHatasi fırlatır (ör. "E-posta veya şifre hatalı.").
  Future<Oturum> girisYap(String eposta, String sifre) async {
    final veri = await _api.post('/api/oturum/giris', {
      'eposta': eposta.trim(),
      'sifre': sifre,
    }) as Map<String, dynamic>;

    final oturum = Oturum.fromJson(veri);
    await TokenDeposu.kaydet(oturum); // otomatik giriş için sakla
    return oturum;
  }

  /// Uygulama açılışında çağrılır. Geçerli bir oturum varsa döndürür, yoksa null.
  Future<Oturum?> kayitliOturum() async {
    final oturum = await TokenDeposu.oku();
    if (oturum == null) return null;

    // Süresi dolmuş token işe yaramaz, silip girişe yönlendireceğiz
    if (oturum.suresiDolduMu) {
      await TokenDeposu.sil();
      return null;
    }
    return oturum;
  }

  /// Çıkış: telefondaki oturumu siler.
  /// JWT sunucuda tutulmadığı için sunucuya istek atmaya gerek yok.
  Future<void> cikisYap() => TokenDeposu.sil();
}