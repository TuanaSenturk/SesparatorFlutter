import 'package:flutter/material.dart';

import '../models/hesap.dart';
import '../models/islem.dart';
import '../services/hesap_servisi.dart';
import '../utils/bicim.dart';
import '../widgets/hata_gorunumu.dart';

/// Hesap detayı: üstte hesap bilgisi, altta işlem geçmişi.
class HesapDetayEkrani extends StatefulWidget {
  const HesapDetayEkrani({super.key, required this.hesap});

  // Hesaplarım'dan gelen hesap. Üstteki kart bunu kullanır, ayrıca istek atmaya gerek yok.
  final Hesap hesap;

  @override
  State<HesapDetayEkrani> createState() => _HesapDetayEkraniState();
}

class _HesapDetayEkraniState extends State<HesapDetayEkrani> {
  final _hesapServisi = HesapServisi();
  late Future<List<Islem>> _islemler;

  @override
  void initState() {
    super.initState();
    _islemler = _hesapServisi.islemleriGetir(widget.hesap.id);
  }

  // Hesaplarım'daki _yenile ile aynı mantık
  Future<void> _yenile() async {
    final yeni = _hesapServisi.islemleriGetir(widget.hesap.id);
    setState(() => _islemler = yeni);
    try {
      await yeni;
    } catch (_) {
      // Hata FutureBuilder tarafından ekranda gösterilir
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Navigator.push ile açıldığı için AppBar'da geri oku kendiliğinden çıkar
      appBar: AppBar(title: Text(widget.hesap.hesapAdi)),
      body: Column(
        children: [
          _HesapBilgiKarti(hesap: widget.hesap), // sabit üst kısım
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Hesap Hareketleri', style: Theme.of(context).textTheme.titleMedium),
            ),
          ),
          // Expanded: Column içindeki kalan alanın tamamını liste kaplasın
          Expanded(
            child: FutureBuilder<List<Islem>>(
              future: _islemler,
              builder: (context, durum) {
                if (durum.connectionState != ConnectionState.done && !durum.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (durum.hasError) {
                  return HataGorunumu(mesaj: '${durum.error}', onTekrarDene: _yenile);
                }
                final islemler = durum.data ?? [];
                if (islemler.isEmpty) {
                  return const Center(child: Text('Bu hesapta henüz işlem yok.'));
                }
                return RefreshIndicator(
                  onRefresh: _yenile,
                  // ListView.builder: satırları sadece ekranda görünürken oluşturur,
                  // uzun işlem listelerinde de hızlı kalır
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: islemler.length,
                    itemBuilder: (context, i) =>
                        _IslemSatiri(islem: islemler[i], paraBirimi: widget.hesap.paraBirimi),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ---- Ekranın parçaları ----

class _HesapBilgiKarti extends StatelessWidget {
  const _HesapBilgiKarti({required this.hesap});

  final Hesap hesap;

  @override
  Widget build(BuildContext context) {
    final renkler = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('IBAN', style: TextStyle(fontSize: 12, color: renkler.onSurfaceVariant)),
            const SizedBox(height: 4),
            Text(Bicim.iban(hesap.iban), style: const TextStyle(fontSize: 16, fontFamily: 'monospace')),
            const SizedBox(height: 12),
            Text('Bakiye', style: TextStyle(fontSize: 12, color: renkler.onSurfaceVariant)),
            const SizedBox(height: 4),
            Text(
              Bicim.para(hesap.bakiye, hesap.paraBirimi),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class _IslemSatiri extends StatelessWidget {
  const _IslemSatiri({required this.islem, required this.paraBirimi});

  final Islem islem;
  final String paraBirimi;

  // İşlem türüne göre simge
  IconData get _simge => switch (islem.islemTuru) {
    'GelenTransfer' => Icons.south_west,   // ↙ içeri
    'KartBorcOdeme' => Icons.credit_card,
    _ => Icons.north_east,                 // ↗ dışarı
  };

  @override
  Widget build(BuildContext context) {
    final renkler = Theme.of(context).colorScheme;
    // Gelen yeşil +, diğerleri kırmızı − (web'deki hesap hareketleri ile aynı)
    final renk = islem.gelenMi ? Colors.green.shade700 : renkler.error;
    final isaret = islem.gelenMi ? '+' : '-';

    // ListTile: [leading] [title / subtitle] [trailing] düzenini hazır verir
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: renkler.primaryContainer,
        child: Icon(_simge, size: 20),
      ),
      // ?? : açıklama boşsa tür adını göster
      title: Text(islem.aciklama ?? islem.turAdi, maxLines: 1, overflow: TextOverflow.ellipsis),
      // Wrap: sığmazsa alt satıra geçer, dar ekranda taşma olmaz
      subtitle: Wrap(
        spacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(Bicim.tarih(islem.tarih)),
          if (islem.sesliMi) const _Etiket(metin: 'Sesli', ikon: Icons.mic),
          if (!islem.tamamlandiMi) _Etiket(metin: islem.durumAdi, ikon: Icons.info_outline),
        ],
      ),
      trailing: Text(
        '$isaret${Bicim.para(islem.tutar, paraBirimi)}',
        style: TextStyle(color: renk, fontWeight: FontWeight.bold),
      ),
    );
  }
}

/// İşlem satırındaki küçük bilgi etiketi ("Sesli", "İptal Edildi")
class _Etiket extends StatelessWidget {
  const _Etiket({required this.metin, required this.ikon});

  final String metin;
  final IconData ikon;

  @override
  Widget build(BuildContext context) {
    final renkler = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: renkler.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // sadece içeriği kadar yer kapla
        children: [
          Icon(ikon, size: 12),
          const SizedBox(width: 3),
          Text(metin, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}
