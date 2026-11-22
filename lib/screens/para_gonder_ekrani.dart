import 'package:flutter/material.dart';
import '../models/hesap.dart';
import '../models/kayitli_alici.dart';
import '../services/api_servisi.dart';
import '../services/hesap_servisi.dart';
import '../services/kayitli_alici_servisi.dart';
import '../services/transfer_servisi.dart';
import '../utils/bicim.dart';
import '../widgets/hata_gorunumu.dart';

class ParaGonderEkrani extends StatefulWidget {
  final KayitliAlici? seciliAlici; // Kayıtlı Alıcılar'dan gelinirse dolu
  const ParaGonderEkrani({super.key, this.seciliAlici});

  @override
  State<ParaGonderEkrani> createState() => _ParaGonderEkraniState();
}

class _ParaGonderEkraniState extends State<ParaGonderEkrani> {
  final _formKey = GlobalKey<FormState>();
  final _tutarKontrol = TextEditingController();
  final _aciklamaKontrol = TextEditingController();
  final _transferServisi = TransferServisi();

  late Future<void> _yukleme;
  Hesap? _vadesiz;
  List<KayitliAlici> _alicilar = [];
  KayitliAlici? _alici;
  bool _gonderiliyor = false;

  @override
  void initState() {
    super.initState();
    _yukleme = _verileriYukle();
  }

  @override
  void dispose() {
    _tutarKontrol.dispose();
    _aciklamaKontrol.dispose();
    super.dispose();
  }

  Future<void> _verileriYukle() async {
    final sonuc = await Future.wait([
      HesapServisi().hesaplariGetir(),
      KayitliAliciServisi().listele(),
    ]);
    final hesaplar = sonuc[0] as List<Hesap>;
    _alicilar = sonuc[1] as List<KayitliAlici>;
    // Sunucu transferi vadesiz TRY hesabından yapıyor
    _vadesiz = hesaplar
        .where((h) => h.hesapTuru == 'Vadesiz' && h.paraBirimi == 'TRY')
        .firstOrNull;
    if (widget.seciliAlici != null) {
      _alici = _alicilar.where((a) => a.id == widget.seciliAlici!.id).firstOrNull;
    }
  }

  void _tekrarDene() {
    // Süslü parantez şart: "=> _yukleme = ..." Future döndürür, setState hata verir
    setState(() {
      _yukleme = _verileriYukle();
    });
  }

  double? _tutarOku() =>
      double.tryParse(_tutarKontrol.text.trim().replaceAll(',', '.'));

  void _mesajGoster(String mesaj, {bool hata = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(mesaj),
      backgroundColor: hata ? Theme.of(context).colorScheme.error : null,
    ));
  }

  Future<void> _gonder() async {
    if (!_formKey.currentState!.validate()) return;
    final tutar = _tutarOku()!;
    final alici = _alici!;

    final onay = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Transferi onaylıyor musunuz?'),
        content: Text(
          '${alici.takmaAd} (${alici.adSoyad})\n'
              '${Bicim.iban(alici.iban)}\n\n'
              'Tutar: ${Bicim.para(tutar)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Onayla'),
          ),
        ],
      ),
    );
    if (onay != true || !mounted) return;

    setState(() {
      _gonderiliyor = true;
    });
    try {
      final mesaj = await _transferServisi.gonder(
        kayitliAliciId: alici.id,
        tutar: tutar,
        aciklama: _aciklamaKontrol.text.trim(),
      );
      if (!mounted) return;
      _mesajGoster(mesaj);
      Navigator.of(context).pop(true); // Hesaplarım yenilensin
    } on ApiHatasi catch (e) {
      if (mounted) _mesajGoster(e.mesaj, hata: true); // limit / bakiye mesajı
    } finally {
      if (mounted) {
        setState(() {
          _gonderiliyor = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Para Gönder')),
      body: FutureBuilder<void>(
        future: _yukleme,
        builder: (context, durum) {
          if (durum.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (durum.hasError) {
            return HataGorunumu(mesaj: '${durum.error}', onTekrarDene: _tekrarDene);
          }
          if (_vadesiz == null) {
            return const Center(child: Text('Transfer için vadesiz hesabınız yok.'));
          }
          if (_alicilar.isEmpty) {
            return const Center(child: Text('Önce Kayıtlı Alıcılar ekranından alıcı ekleyin.'));
          }
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.account_balance),
                    title: Text(_vadesiz!.hesapAdi),
                    subtitle: Text(
                      '${Bicim.iban(_vadesiz!.iban)}\n'
                          'Bakiye: ${Bicim.para(_vadesiz!.bakiye, _vadesiz!.paraBirimi)}',
                    ),
                    isThreeLine: true,
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<KayitliAlici>(
                  initialValue: _alici,
                  decoration: const InputDecoration(labelText: 'Alıcı'),
                  items: _alicilar
                      .map((a) => DropdownMenuItem(
                    value: a,
                    child: Text('${a.takmaAd} — ${a.adSoyad}'),
                  ))
                      .toList(),
                  onChanged: (a) {
                    setState(() {
                      _alici = a;
                    });
                  },
                  validator: (a) => a == null ? 'Alıcı seçin' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _tutarKontrol,
                  decoration: const InputDecoration(labelText: 'Tutar', suffixText: '₺'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (_) {
                    final t = _tutarOku();
                    if (t == null || t <= 0) return 'Geçerli bir tutar girin';
                    if (t > _vadesiz!.bakiye) return 'Bakiyeniz yetersiz';
                    return null; // limit kontrolü sunucuda
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _aciklamaKontrol,
                  decoration: const InputDecoration(labelText: 'Açıklama (isteğe bağlı)'),
                  maxLength: 100,
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _gonderiliyor ? null : _gonder,
                  icon: _gonderiliyor
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Icon(Icons.send),
                  label: const Text('Gönder'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}