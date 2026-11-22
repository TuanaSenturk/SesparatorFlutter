import 'asistan_yaniti.dart';

enum Gonderen { kullanici, asistan }

/// Sohbet ekranındaki bir balon. API'den gelmez, uygulama içinde tutulur.
class SohbetMesaji {
  SohbetMesaji({
    required this.gonderen,
    required this.metin,
    this.hata = false,
    this.bekleyenTransfer,
    DateTime? zaman,
  }) : zaman = zaman ?? DateTime.now();

  /// Kullanıcının yazdığı mesaj
  SohbetMesaji.kullanici(String metin) : this(gonderen: Gonderen.kullanici, metin: metin);

  /// Asistanın yanıtı (onay bekleyen transfer varsa onunla birlikte)
  SohbetMesaji.asistan(String metin, {BekleyenTransfer? bekleyenTransfer})
    : this(gonderen: Gonderen.asistan, metin: metin, bekleyenTransfer: bekleyenTransfer);

  /// Bağlantı / sunucu hatası (kırmızı balon)
  SohbetMesaji.hata(String metin) : this(gonderen: Gonderen.asistan, metin: metin, hata: true);

  final Gonderen gonderen;
  final String metin;
  final DateTime zaman;
  final bool hata;
  final BekleyenTransfer? bekleyenTransfer; // varsa balonun içinde özet kart çizilir

  bool get kullanicidanMi => gonderen == Gonderen.kullanici;
}
