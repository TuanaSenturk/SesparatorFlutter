import '../models/kayitli_alici.dart';
import 'api_servisi.dart';

/// Kayıtlı alıcılar için CRUD istekleri.
class KayitliAliciServisi {
  final ApiServisi _api = ApiServisi();

  /// GET /api/kayitli-alicilar -> List<KayitliAlici>
  Future<List<KayitliAlici>> listele() async {
    final veri = await _api.get('/api/kayitli-alicilar') as List<dynamic>;
    return veri.map((oge) => KayitliAlici.fromJson(oge as Map<String, dynamic>)).toList();
  }

  /// POST /api/kayitli-alicilar
  Future<void> ekle(String takmaAd, String adSoyad, String iban) async {
    await _api.post('/api/kayitli-alicilar', _govde(takmaAd, adSoyad, iban));
  }

  /// PUT /api/kayitli-alicilar/{id}
  Future<void> guncelle(int id, String takmaAd, String adSoyad, String iban) async {
    await _api.put('/api/kayitli-alicilar/$id', _govde(takmaAd, adSoyad, iban));
  }

  /// DELETE /api/kayitli-alicilar/{id}
  Future<void> sil(int id) async {
    await _api.delete('/api/kayitli-alicilar/$id');
  }

  // API'deki KayitliAliciGirdisi ile aynı alanlar
  Map<String, dynamic> _govde(String takmaAd, String adSoyad, String iban) => {
    'takmaAd': takmaAd.trim(),
    'adSoyad': adSoyad.trim(),
    'iban': iban,
  };
}