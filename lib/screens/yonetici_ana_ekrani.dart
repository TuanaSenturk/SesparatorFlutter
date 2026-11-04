import 'package:flutter/material.dart';

import '../models/oturum.dart';
import 'hazirlaniyor_ekrani.dart';

/// Yöneticinin ana ekranı: müşteri ekranlarından ayrı, kendi menüsü var.
class YoneticiAnaEkrani extends StatefulWidget {
  const YoneticiAnaEkrani({super.key, required this.oturum});

  final Oturum oturum;

  @override
  State<YoneticiAnaEkrani> createState() => _YoneticiAnaEkraniState();
}

class _YoneticiAnaEkraniState extends State<YoneticiAnaEkrani> {
  int _seciliSekme = 0;

  final List<Widget> _sekmeler = const [
    HazirlaniyorEkrani(
      baslik: 'Müşteriler',
      ikon: Icons.people,
      aciklama: 'Müşteri listesi 8. haftada eklenecek.',
    ),
    HazirlaniyorEkrani(
      baslik: 'İşlemler',
      ikon: Icons.receipt_long,
      aciklama: 'İşlem izleme 8. haftada eklenecek.',
    ),
    HazirlaniyorEkrani(
      baslik: 'Asistan Kayıtları',
      ikon: Icons.forum,
      aciklama: 'Konuşma kayıtları ve anlaşılamayan komutlar 8. haftada eklenecek.',
    ),
    HazirlaniyorEkrani(
      baslik: 'Ayarlar',
      ikon: Icons.settings,
      aciklama: 'Günlük sesli işlem limiti ayarı 8. haftada eklenecek.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _seciliSekme, children: _sekmeler),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _seciliSekme,
        onDestinationSelected: (i) => setState(() => _seciliSekme = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: 'Müşteriler'),
          NavigationDestination(icon: Icon(Icons.receipt_long), label: 'İşlemler'),
          NavigationDestination(icon: Icon(Icons.forum_outlined), selectedIcon: Icon(Icons.forum), label: 'Kayıtlar'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Ayarlar'),
        ],
      ),
    );
  }
}