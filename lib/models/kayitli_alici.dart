/// Kullanıcının kayıtlı alıcısı. Web API'deki KayitliAliciDto'nun karşılığı.
class KayitliAlici {
  const KayitliAlici({
    required this.id,
    required this.takmaAd,
    required this.adSoyad,
    required this.iban,
  });

  final int id;
  final String takmaAd; // "Annem", "Kızım"
  final String adSoyad;
  final String iban;    // sunucu boşluksuz saklar: TR33...

  factory KayitliAlici.fromJson(Map<String, dynamic> json) {
    return KayitliAlici(
      id: json['id'] as int,
      takmaAd: json['takmaAd'] as String,
      adSoyad: json['adSoyad'] as String,
      iban: json['iban'] as String,
    );
  }
}