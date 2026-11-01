/// API'den gelen bir hesap. Web API'deki HesapDto'nun karşılığı.
class Hesap {
  const Hesap({
    required this.id,
    required this.iban,
    required this.hesapTuru,
    required this.paraBirimi,
    required this.bakiye,
  });

  final int id;
  final String iban;
  final String hesapTuru; // "Vadesiz" veya "Vadeli"
  final String paraBirimi; // "TRY"
  final double bakiye;

  /// JSON'daki bir nesneyi Hesap'a çevirir.
  /// factory: her seferinde yeni nesne oluşturmak zorunda olmayan constructor türü.
  factory Hesap.fromJson(Map<String, dynamic> json) {
    return Hesap(
      id: json['id'] as int,
      iban: json['iban'] as String,
      hesapTuru: json['hesapTuru'] as String,
      paraBirimi: json['paraBirimi'] as String,
      // bakiye JSON'da 71900 (int) ya da 71900.5 (double) gelebilir, ikisi de num
      bakiye: (json['bakiye'] as num).toDouble(),
    );
  }

  String get hesapAdi => '$hesapTuru Hesap'; // "Vadesiz Hesap"
}