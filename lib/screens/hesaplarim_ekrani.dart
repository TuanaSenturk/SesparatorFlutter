import 'package:flutter/material.dart';

import '../models/hesap.dart';
import '../services/hesap_servisi.dart';
import '../utils/bicim.dart';
import 'giris_ekrani.dart';

/// Hesaplarım: kullanıcının hesapları, IBAN ve bakiyeleri.
class HesaplarimEkrani extends StatefulWidget {
  const HesaplarimEkrani({super.key});

  @override
  State<HesaplarimEkrani> createState() => _HesaplarimEkraniState();
}

class _HesaplarimEkraniState extends State<HesaplarimEkrani> {
  final _hesapServisi = HesapServisi();

  // late: değeri hemen değil, initState'te verilecek
  late Future<List<Hesap>> _hesaplar;

  // initState: ekran ilk açıldığında BİR KEZ çalışır.
  // İsteği build içinde değil burada başlatıyoruz; yoksa her yeniden çizimde tekrar istek atılır.
  @override
  void initState() {
    super.initState();
    _hesaplar = _hesapServisi.hesaplariGetir();
  }

  void _yenidenDene() {
    setState(() {
      _hesaplar = _hesapServisi.hesaplariGetir();
    });
  }

  void _cikisYap() {
    // pushReplacement: mevcut ekranı yenisiyle değiştirir (geri tuşuyla dönülmez)
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const GirisEkrani()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hesaplarım'),
        actions: [
          IconButton(
            tooltip: 'Çıkış yap',
            icon: const Icon(Icons.logout),
            onPressed: _cikisYap,
          ),
        ],
      ),
      // FutureBuilder: Future'ın durumuna göre (bekliyor / hata / veri geldi) farklı ekran çizer
      body: FutureBuilder<List<Hesap>>(
        future: _hesaplar,
        builder: (context, durum) {
          // 1) Henüz cevap gelmedi
          if (durum.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          // 2) Hata oluştu (ApiHatasi mesajı burada görünür)
          if (durum.hasError) {
            return _HataGorunumu(mesaj: '${durum.error}', onTekrarDene: _yenidenDene);
          }
          // 3) Veri geldi
          final hesaplar = durum.data ?? [];
          if (hesaplar.isEmpty) {
            return const Center(child: Text('Henüz bir hesabınız yok.'));
          }
          return _HesapListesi(hesaplar: hesaplar);
        },
      ),
    );
  }
}

// ---- Ekranın parçaları: küçük widget'lara bölmek okumayı kolaylaştırır ----

class _HesapListesi extends StatelessWidget {
  const _HesapListesi({required this.hesaplar});

  final List<Hesap> hesaplar;

  @override
  Widget build(BuildContext context) {
    // TL hesaplarının toplamı. fold: listeyi tek bir değere indirger.
    final toplamTl = hesaplar
        .where((h) => h.paraBirimi == 'TRY')
        .fold<double>(0, (toplam, h) => toplam + h.bakiye);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _ToplamBakiyeKarti(toplam: toplamTl),
        const SizedBox(height: 16),
        for (final hesap in hesaplar) _HesapKarti(hesap: hesap), // listedeki her hesap için bir kart
      ],
    );
  }
}

class _ToplamBakiyeKarti extends StatelessWidget {
  const _ToplamBakiyeKarti({required this.toplam});

  final double toplam;

  @override
  Widget build(BuildContext context) {
    final renkler = Theme.of(context).colorScheme;

    return Card(
      color: renkler.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Toplam Bakiye', style: TextStyle(color: renkler.onPrimary, fontSize: 16)),
            const SizedBox(height: 8),
            Text(
              Bicim.para(toplam),
              style: TextStyle(color: renkler.onPrimary, fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class _HesapKarti extends StatelessWidget {
  const _HesapKarti({required this.hesap});

  final Hesap hesap;

  @override
  Widget build(BuildContext context) {
    final renkler = Theme.of(context).colorScheme;
    final vadesiz = hesap.hesapTuru == 'Vadesiz';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        // Row: yan yana dizer -> [simge] [ad + IBAN] [bakiye]
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: renkler.primaryContainer,
              child: Icon(vadesiz ? Icons.account_balance_wallet : Icons.savings),
            ),
            const SizedBox(width: 16),
            // Expanded: kalan boş alanın tamamını kaplar, uzun IBAN taşmaz
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(hesap.hesapAdi, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(Bicim.iban(hesap.iban), style: TextStyle(fontSize: 12, color: renkler.onSurfaceVariant)),
                ],
              ),
            ),
            Text(
              Bicim.para(hesap.bakiye, hesap.paraBirimi),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class _HataGorunumu extends StatelessWidget {
  const _HataGorunumu({required this.mesaj, required this.onTekrarDene});

  final String mesaj;
  final VoidCallback onTekrarDene; // parametresiz fonksiyon

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, size: 48, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 12),
            Text(mesaj, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onTekrarDene,
              icon: const Icon(Icons.refresh),
              label: const Text('Tekrar dene'),
            ),
          ],
        ),
      ),
    );
  }
}