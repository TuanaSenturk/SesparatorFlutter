/// Onay bekleyen transfer. Web API'deki BekleyenTransfer'in karşılığı.
class BekleyenTransfer {
  const BekleyenTransfer({
    required this.hesapId,
    required this.kayitliAliciId,
    required this.aliciAdSoyad,
    required this.aliciIban,
    required this.tutar,
  });

  final int hesapId;
  final int kayitliAliciId;
  final String aliciAdSoyad;
  final String aliciIban;
  final double tutar;

  factory BekleyenTransfer.fromJson(Map<String, dynamic> json) {
    return BekleyenTransfer(
      hesapId: json['hesapId'] as int,
      kayitliAliciId: json['kayitliAliciId'] as int,
      aliciAdSoyad: json['aliciAdSoyad'] as String,
      aliciIban: json['aliciIban'] as String,
      // tutar JSON'da 500 (int) ya da 500.5 (double) gelebilir, ikisi de num
      tutar: (json['tutar'] as num).toDouble(),
    );
  }
}

/// POST /api/asistan/mesaj yanıtı. Web API'deki AsistanYaniti'nin karşılığı.
class AsistanYaniti {
  const AsistanYaniti({
    required this.mesaj,
    required this.niyet,
    required this.onayGerekli,
    required this.bekleyenTransfer,
    required this.islemId,
  });

  final String mesaj;
  final String niyet;       // BAKIYE_SORGULA, PARA_TRANSFERI, BILINMIYOR, ONAY, IPTAL
  final bool onayGerekli;
  final BekleyenTransfer? bekleyenTransfer; // sadece onayGerekli true iken dolu
  final int? islemId;       // onay bekleyen işlemin Id'si (main'deki API göndermez, null gelir)

  factory AsistanYaniti.fromJson(Map<String, dynamic> json) {
    final transfer = json['bekleyenTransfer'];
    return AsistanYaniti(
      mesaj: json['mesaj'] as String,
      niyet: json['niyet'] as String,
      onayGerekli: json['onayGerekli'] as bool? ?? false,
      bekleyenTransfer:
          transfer == null ? null : BekleyenTransfer.fromJson(transfer as Map<String, dynamic>),
      islemId: json['islemId'] as int?,
    );
  }
}
