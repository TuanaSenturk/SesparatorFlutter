import '../models/hesap.dart';
import 'api_servisi.dart';

/// Hesaplarla ilgili API istekleri.
class HesapServisi {
  final ApiServisi _api = ApiServisi();

  /// GET /api/hesaplar -> List<Hesap>
  Future<List<Hesap>> hesaplariGetir() async {
    final veri = await _api.get('/api/hesaplar') as List<dynamic>;
    // JSON listesindeki her öğeyi Hesap nesnesine çevir
    return veri.map((oge) => Hesap.fromJson(oge as Map<String, dynamic>)).toList();
  }
}