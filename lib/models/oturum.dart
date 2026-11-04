/// Giriş yapan kullanıcının oturumu.
/// API'nin POST /api/oturum/giris yanıtının (TokenYaniti) karşılığı:
/// { "token": "...", "bitisZamani": "2026-11-01T10:00:00Z", "ad": "Ayşe", "soyad": "Yılmaz", "roller": ["Musteri"] }
class Oturum {
  const Oturum({
    required this.token,
    required this.bitisZamani,
    required this.ad,
    required this.soyad,
    required this.roller,
  });

  final String token;          // her istekte "Authorization: Bearer <token>" olarak gönderilecek
  final DateTime bitisZamani;  // token bu zamandan sonra geçersiz
  final String ad;
  final String soyad;
  final List<String> roller;   // "Musteri" veya "Yonetici"

  factory Oturum.fromJson(Map<String, dynamic> json) {
    return Oturum(
      token: json['token'] as String,
      // Sunucu UTC gönderiyor (sonunda Z var); DateTime.parse bunu doğru okur
      bitisZamani: DateTime.parse(json['bitisZamani'] as String),
      ad: json['ad'] as String,
      soyad: json['soyad'] as String,
      // JSON listesi List<dynamic> gelir, cast ile List<String>'e çeviriyoruz
      roller: (json['roller'] as List<dynamic>).cast<String>(),
    );
  }

  /// Telefonda saklamak için tekrar JSON'a çevirir (fromJson'ın tersi).
  Map<String, dynamic> toJson() => {
    'token': token,
    'bitisZamani': bitisZamani.toIso8601String(),
    'ad': ad,
    'soyad': soyad,
    'roller': roller,
  };

  bool get yoneticiMi => roller.contains('Yonetici');

  bool get suresiDolduMu => DateTime.now().isAfter(bitisZamani);

  String get adSoyad => '$ad $soyad';
}