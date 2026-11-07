import 'package:intl/intl.dart';

/// Web'deki Helpers/Bicim.cs ile aynı biçimler.
class Bicim {
  static final NumberFormat _sayi = NumberFormat('#,##0.00', 'tr_TR');
  static final DateFormat _tarih = DateFormat('dd.MM.yyyy HH:mm', 'tr_TR');

  /// 71900 -> "71.900,00 TL"
  static String para(double tutar, [String paraBirimi = 'TRY']) {
    final metin = _sayi.format(tutar);
    return paraBirimi == 'TRY' ? '$metin TL' : '$metin $paraBirimi';
  }

  /// TR260099907181000301488803 -> "TR26 0099 9071 8100 0301 4888 03"
  static String iban(String iban) {
    final parcalar = <String>[];
    for (var i = 0; i < iban.length; i += 4) {
      final son = i + 4 < iban.length ? i + 4 : iban.length;
      parcalar.add(iban.substring(i, son));
    }
    return parcalar.join(' ');
  }

  /// 2026-09-14 20:00 -> "14.09.2026 20:00" (web'deki tarih biçimi ile aynı)
  static String tarih(DateTime tarih) => _tarih.format(tarih);
}