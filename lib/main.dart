import 'package:flutter/material.dart';

import 'screens/giris_ekrani.dart';

// Uygulama buradan başlar. runApp, verilen widget'ı ekrana çizer.
void main() {
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
      home: const GirisEkrani(), // açılışta gösterilecek ekran
    );
  }
}