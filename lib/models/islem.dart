/// API'den gelen bir hesap işlemi. Web API'deki IslemDto'nun karşılığı.
class Islem {
  const Islem({
    required this.id,
    required this.islemTuru,
    required this.tutar,
    required this.aliciIban,
    required this.aciklama,
    required this.tarih,
    required this.kanal,
    required this.durum,
  });

  final int id;
  final String islemTuru;   // "GidenTransfer", "GelenTransfer" veya "KartBorcOdeme"
  final double tutar;       // her zaman pozitif; yönü islemTuru belirler
  final String? aliciIban;  // ? : boş olabilir (ör. kart borcu ödemesinde alıcı yok)
  final String? aciklama;
  final DateTime tarih;
  final String kanal;       // "Web" veya "Ses"
  final String durum;       // "Beklemede", "Tamamlandi", "IptalEdildi" veya "Basarisiz"

  factory Islem.fromJson(Map<String, dynamic> json) {
    return Islem(
      id: json['id'] as int,
      islemTuru: json['islemTuru'] as String,
      // tutar JSON'da 1650 (int) ya da 1650.5 (double) gelebilir, ikisi de num
      tutar: (json['tutar'] as num).toDouble(),
      aliciIban: json['aliciIban'] as String?,
      aciklama: json['aciklama'] as String?,
      // Sunucu "2026-09-14T20:00:00" gönderiyor (sonunda Z yok), yerel saat olarak okunur
      tarih: DateTime.parse(json['tarih'] as String),
      kanal: json['kanal'] as String,
      durum: json['durum'] as String,
    );
  }

  bool get gelenMi => islemTuru == 'GelenTransfer';

  bool get sesliMi => kanal == 'Ses';

  bool get tamamlandiMi => durum == 'Tamamlandi';

  /// Ekranda gösterilecek tür adı (web'deki Bicim.IslemTuruAdi ile aynı)
  String get turAdi => switch (islemTuru) {
    'GidenTransfer' => 'Giden Transfer',
    'GelenTransfer' => 'Gelen Transfer',
    'KartBorcOdeme' => 'Kart Borcu Ödemesi',
    _ => islemTuru, // bilinmeyen bir tür gelirse olduğu gibi göster
  };

  String get durumAdi => switch (durum) {
    'Beklemede' => 'Beklemede',
    'Tamamlandi' => 'Tamamlandı',
    'IptalEdildi' => 'İptal Edildi',
    'Basarisiz' => 'Başarısız',
    _ => durum,
  };
}
