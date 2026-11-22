import 'api_servisi.dart';

class TransferServisi {
  final ApiServisi _api = ApiServisi();

  Future<String> gonder({
    required int kayitliAliciId,
    required double tutar,
    String? aciklama,
  }) async {
    final yanit = await _api.post('/api/transferler', {
      'kayitliAliciId': kayitliAliciId,
      'tutar': tutar,
      if (aciklama != null && aciklama.isNotEmpty) 'aciklama': aciklama,
    });
    return yanit['mesaj'] as String;
  }
}