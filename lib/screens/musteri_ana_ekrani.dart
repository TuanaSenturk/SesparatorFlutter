import 'package:flutter/material.dart';

import '../models/oturum.dart';
import 'hazirlaniyor_ekrani.dart';
import 'hesaplarim_ekrani.dart';

/// Müşterinin ana ekranı: altta NavigationBar, üstte seçili sekme.
class MusteriAnaEkrani extends StatefulWidget {
  const MusteriAnaEkrani({super.key, required this.oturum});

  final Oturum oturum;

  @override
  State<MusteriAnaEkrani> createState() => _MusteriAnaEkraniState();
}

class _MusteriAnaEkraniState extends State<MusteriAnaEkrani> {
  int _seciliSekme = 0;

  // Sekmeler bir kez oluşturulur. IndexedStack hepsini canlı tutar, sadece seçileni gösterir.
  // Böylece sekme değiştirince Hesaplarım'daki veri ve kaydırma konumu kaybolmaz.
  // late: widget.oturum'a erişmek için. Normal alan başlatılırken widget henüz kullanılamaz.
  late final List<Widget> _sekmeler = [
    HesaplarimEkrani(oturum: widget.oturum),
    HazirlaniyorEkrani(
      baslik: 'Asistan',
      ikon: Icons.mic,
      aciklama: 'Sesli asistan 4. haftada eklenecek.',
    ),
    HazirlaniyorEkrani(
      baslik: 'Kartlarım',
      ikon: Icons.credit_card,
      aciklama: 'Kartlarım ekranı 7. haftada eklenecek.',
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
          NavigationDestination(
            icon: Icon(Icons.account_balance_outlined),
            selectedIcon: Icon(Icons.account_balance),
            label: 'Hesaplarım',
          ),
          NavigationDestination(icon: Icon(Icons.mic_none), selectedIcon: Icon(Icons.mic), label: 'Asistan'),
          NavigationDestination(icon: Icon(Icons.credit_card), label: 'Kartlar'),
        ],
      ),
    );
  }
}