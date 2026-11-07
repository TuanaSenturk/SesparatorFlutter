import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/acilis_ekrani.dart';

// Uygulama buradan başlar. runApp, verilen widget'ı ekrana çizer.
// async: Türkçe tarih verisinin yüklenmesini bekleyebilmek için
Future<void> main() async {
  // DateFormat'ın 'tr_TR' ile çalışması için Türkçe ay/gün adlarını yükler.
  // Bu satır olmazsa ilk tarih biçimlendirmede LocaleDataException hatası alınır.
  await initializeDateFormatting('tr_TR');
  runApp(const SesparatorUygulamasi());
}

// StatelessWidget: kendi içinde değişen bir verisi olmayan widget.
class SesparatorUygulamasi extends StatelessWidget {
  const SesparatorUygulamasi({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp: tema, sayfa geçişleri (Navigator) gibi altyapıyı kurar.
    return MaterialApp(
      title: 'Sesparator',
      debugShowCheckedModeBanner: false, // sağ üstteki "DEBUG" şeridini gizler
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF4E73DF), // web'deki SB Admin mavisi
        useMaterial3: true,
      ),
      home: const AcilisEkrani(), // oturumu kontrol edip girişe ya da ana ekrana yönlendirir
    );
  }
}