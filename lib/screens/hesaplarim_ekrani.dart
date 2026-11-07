import 'package:flutter/material.dart';

import '../models/hesap.dart';
import '../models/oturum.dart';
import '../services/hesap_servisi.dart';
import '../utils/bicim.dart';
import '../widgets/cikis_butonu.dart';
import '../widgets/hata_gorunumu.dart';
import 'hesap_detay_ekrani.dart';

/// Hesaplarım: kullanıcının hesapları, IBAN ve bakiyeleri.
class HesaplarimEkrani extends StatefulWidget {
  const HesaplarimEkrani({super.key, required this.oturum});

  final Oturum oturum;

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

  // RefreshIndicator bir Future bekler; Future bitince dönen gösterge kapanır.
  Future<void> _yenile() async {
    final yeni = _hesapServisi.hesaplariGetir();
    setState(() => _hesaplar = yeni);
    try {
      await yeni;
    } catch (_) {
      // Hata FutureBuilder tarafından ekranda gösterilir, burada bir şey yapmaya gerek yok
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hesaplarım'),
        actions: const [CikisButonu()],
      ),
      // FutureBuilder: Future'ın durumuna göre (bekliyor / hata / veri geldi) farklı ekran çizer
      body: FutureBuilder<List<Hesap>>(
        future: _hesaplar,
        builder: (context, durum) {
            //Sadece İLK yüklemede tam ekran gösterge. Yenilerken eski liste ekranda kalır.
            if (durum.connectionState != ConnectionState.done && !durum.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
          // 2) Hata oluştu (ApiHatasi mesajı burada görünür)
          if (durum.hasError) {
            return HataGorunumu(mesaj: '${durum.error}', onTekrarDene: _yenile);
          }
          // 3) Veri geldi
          final hesaplar = durum.data ?? [];
          if (hesaplar.isEmpty) {
            return const Center(child: Text('Henüz bir hesabınız yok.'));
          }
          // RefreshIndicator: listeyi aşağı çekince onRefresh çalışır
          return RefreshIndicator(
            onRefresh: _yenile,
            child: _HesapListesi(hesaplar: hesaplar, ad: widget.oturum.ad),
          );        },
      ),
    );
  }
}

// ---- Ekranın parçaları: küçük widget'lara bölmek okumayı kolaylaştırır ----

class _HesapListesi extends StatelessWidget {
  const _HesapListesi({required this.hesaplar, required this.ad});

  final List<Hesap> hesaplar;
  final String ad;

  @override
  Widget build(BuildContext context) {
    // TL hesaplarının toplamı. fold: listeyi tek bir değere indirger.
    final toplamTl = hesaplar
        .where((h) => h.paraBirimi == 'TRY')
        .fold<double>(0, (toplam, h) => toplam + h.bakiye);

    return ListView(
      padding: const EdgeInsets.all(16),
      // Liste kısa olsa bile aşağı çekilebilsin (yoksa ekranı doldurmayan liste kaydırılamaz)
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        Text('Merhaba, $ad', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
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
      // clipBehavior: dokunma dalgası kartın yuvarlak köşelerinden taşmasın
      clipBehavior: Clip.antiAlias,
      // InkWell: dokunulabilir yapar ve dokununca dalga efekti verir
      child: InkWell(
        // push: yeni ekranı üste ekler, geri tuşu bu ekrana döner
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => HesapDetayEkrani(hesap: hesap)),
        ),
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
      ),
    );
  }
}