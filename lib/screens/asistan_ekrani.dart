import 'package:flutter/material.dart';

import '../models/sohbet_mesaji.dart';
import '../services/api_servisi.dart';
import '../services/asistan_servisi.dart';
import '../widgets/cikis_butonu.dart';
import '../widgets/mesaj_balonu.dart';
import '../widgets/mikrofon_butonu.dart';

/// Asistan sekmesi: yazılı komut gönderme ve mesaj balonları.
class AsistanEkrani extends StatefulWidget {
  const AsistanEkrani({super.key});

  @override
  State<AsistanEkrani> createState() => _AsistanEkraniState();
}

class _AsistanEkraniState extends State<AsistanEkrani> {
  // Dokununca gönderilen örnek komutlar
  static const _oneriler = ['Bakiyem ne kadar?', 'Anneme 500 TL gönder'];

  final _servis = AsistanServisi();
  final _metin = TextEditingController();
  final List<SohbetMesaji> _mesajlar = [
    SohbetMesaji.asistan(
      'Merhaba! Bakiyenizi sorabilir ya da kayıtlı alıcılarınıza para gönderebilirsiniz.',
    ),
  ];
  bool _bekleniyor = false; // yanıt gelene kadar gönder butonu pasif
  bool _dinleniyor = false; // mikrofon kayıttayken metin kutusu salt okunur

  @override
  void dispose() {
    _metin.dispose();
    super.dispose();
  }

  /// [metin] verilirse (öneri çipi) onu, verilmezse metin alanındakini gönderir.
  Future<void> _gonder([String? metin]) async {
    final gonderilecek = (metin ?? _metin.text).trim();
    if (gonderilecek.isEmpty || _bekleniyor) return; // boş mesaj ve çift gönderim engeli

    setState(() {
      _mesajlar.add(SohbetMesaji.kullanici(gonderilecek));
      _bekleniyor = true;
    });
    _metin.clear();

    try {
      final yanit = await _servis.mesajGonder(gonderilecek);
      if (!mounted) return; // ekran kapandıysa setState çağırma
      setState(() => _mesajlar.add(SohbetMesaji.asistan(
            yanit.mesaj,
            bekleyenTransfer: yanit.onayGerekli ? yanit.bekleyenTransfer : null,
          )));
    } on ApiHatasi catch (e) {
      if (!mounted) return;
      setState(() => _mesajlar.add(SohbetMesaji.hata(e.mesaj)));
    } finally {
      if (mounted) setState(() => _bekleniyor = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // "Yazıyor" göstergesi listenin en altında ek bir satır olarak çizilir
    final satirSayisi = _mesajlar.length + (_bekleniyor ? 1 : 0);

    return Scaffold(
      appBar: AppBar(title: const Text('Asistan'), actions: const [CikisButonu()]),
      body: Column(
        children: [
          Expanded(
            // reverse: liste alttan başlar, yeni mesaj gelince kaydırma kendiliğinden altta kalır.
            // Bu yüzden 0. satır en alttaki (en yeni) satırdır, indeks ters çevrilir.
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(12),
              itemCount: satirSayisi,
              itemBuilder: (context, i) {
                if (_bekleniyor && i == 0) return const _YaziyorGostergesi();
                final sira = _bekleniyor ? i - 1 : i; // gösterge varsa bir kaydır
                return MesajBalonu(mesaj: _mesajlar[_mesajlar.length - 1 - sira]);
              },
            ),
          ),
          _OneriCipleri(oneriler: _oneriler, aktif: !_bekleniyor, onSecildi: _gonder),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _metin,
                      readOnly: _dinleniyor,
                      minLines: 1,
                      maxLines: 4,
                      maxLength: 1000, // API'deki MaxLength(1000) kuralı
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _gonder(),
                      decoration: InputDecoration(
                        hintText: _dinleniyor
                            ? 'Dinleniyor… bitirmek için tekrar dokunun'
                            : 'Bir komut yazın…',
                        border: const OutlineInputBorder(),
                        counterText: '', // karakter sayacını gizle
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Dokun-konuş: algılanan metin yazılı komutla aynı yoldan asistana gider
                  MikrofonButonu(
                    aktif: !_bekleniyor,
                    onMetin: (metin) => _gonder(metin),
                    // Anlaşılamadı / bağlantı / izin hataları yazılı komuttaki gibi sohbette görünür
                    onHata: (mesaj) {
                      if (!mounted) return; // yanıt gelmeden çıkış yapıldıysa
                      setState(() {
                        _mesajlar.add(SohbetMesaji.hata(mesaj));
                      });
                    },
                    onDurumDegisti: (dinleniyor) {
                      if (!mounted) return;
                      setState(() {
                        _dinleniyor = dinleniyor;
                      });
                    },
                  ),
                  const SizedBox(width: 4),
                  IconButton.filled(
                    tooltip: 'Gönder',
                    icon: const Icon(Icons.send),
                    onPressed: _bekleniyor ? null : () => _gonder(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Asistan yanıtı beklenirken sol tarafta görünen "yazıyor" balonu
class _YaziyorGostergesi extends StatelessWidget {
  const _YaziyorGostergesi();

  @override
  Widget build(BuildContext context) {
    final renkler = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: renkler.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
            const SizedBox(width: 8),
            Text('Asistan yazıyor…', style: TextStyle(color: renkler.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

/// Giriş alanının üstündeki örnek komutlar; dokununca mesaj gönderilir
class _OneriCipleri extends StatelessWidget {
  const _OneriCipleri({required this.oneriler, required this.aktif, required this.onSecildi});

  final List<String> oneriler;
  final bool aktif; // yanıt beklenirken çipler pasif
  final ValueChanged<String> onSecildi;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          for (final oneri in oneriler)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ActionChip(
                label: Text(oneri),
                onPressed: aktif ? () => onSecildi(oneri) : null,
              ),
            ),
        ],
      ),
    );
  }
}
