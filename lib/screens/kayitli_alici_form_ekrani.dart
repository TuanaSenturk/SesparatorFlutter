import 'package:flutter/material.dart';

import '../models/kayitli_alici.dart';
import '../services/api_servisi.dart';
import '../services/kayitli_alici_servisi.dart';
import '../utils/iban_dogrulama.dart';

/// Kayıtlı alıcı ekleme ve düzenleme formu.
/// alici null ise yeni kayıt, doluysa düzenleme.
class KayitliAliciFormEkrani extends StatefulWidget {
  const KayitliAliciFormEkrani({super.key, this.alici});

  final KayitliAlici? alici;

  @override
  State<KayitliAliciFormEkrani> createState() => _KayitliAliciFormEkraniState();
}

class _KayitliAliciFormEkraniState extends State<KayitliAliciFormEkrani> {
  final _formAnahtari = GlobalKey<FormState>();
  final _servis = KayitliAliciServisi();

  // Düzenlemede alanlar mevcut değerlerle dolu açılır (late: widget'a erişmek için)
  late final _takmaAdKontrol = TextEditingController(text: widget.alici?.takmaAd);
  late final _adSoyadKontrol = TextEditingController(text: widget.alici?.adSoyad);
  late final _ibanKontrol = TextEditingController(text: widget.alici?.iban);

  bool _kaydediliyor = false;

  bool get _duzenlemeMi => widget.alici != null;

  @override
  void dispose() {
    _takmaAdKontrol.dispose();
    _adSoyadKontrol.dispose();
    _ibanKontrol.dispose();
    super.dispose();
  }

  // ---- Doğrulayıcılar: sunucudaki KayitliAliciGirdisi kurallarıyla aynı ----

  String? _takmaAdDogrula(String? deger) {
    final metin = deger?.trim() ?? '';
    if (metin.isEmpty) return 'Takma ad zorunludur.';
    if (metin.length < 2) return 'Takma ad 2-30 karakter olmalıdır.';
    return null;
  }

  String? _adSoyadDogrula(String? deger) {
    final metin = deger?.trim() ?? '';
    if (metin.isEmpty) return 'Alıcının adı soyadı zorunludur.';
    if (metin.length < 3) return 'Ad soyad 3-100 karakter olmalıdır.';
    if (!RegExp(r"^[a-zA-ZçÇğĞıİöÖşŞüÜ\s.'-]+$").hasMatch(metin)) {
      return 'Ad soyad yalnızca harf içermelidir.';
    }
    return null;
  }

  Future<void> _kaydet() async {
    if (_kaydediliyor) return; // çift tıklamayı engelle
    if (!_formAnahtari.currentState!.validate()) return;

    setState(() => _kaydediliyor = true);
    final iban = IbanDogrulama.temizle(_ibanKontrol.text);

    try {
      if (_duzenlemeMi) {
        await _servis.guncelle(widget.alici!.id, _takmaAdKontrol.text, _adSoyadKontrol.text, iban);
      } else {
        await _servis.ekle(_takmaAdKontrol.text, _adSoyadKontrol.text, iban);
      }
      if (!mounted) return;
      Navigator.of(context).pop(true); // true: liste ekranı yenilensin
    } on ApiHatasi catch (hata) {
      // Ör. "Bu IBAN zaten "Annem" adıyla kayıtlı."
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(hata.mesaj)));
      setState(() => _kaydediliyor = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_duzenlemeMi ? 'Alıcıyı Düzenle' : 'Yeni Alıcı')),
      body: Form(
        key: _formAnahtari,
        child: ListView( // klavye açılınca taşmasın, kaydırılabilsin
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _takmaAdKontrol,
              maxLength: 30,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Takma ad',
                hintText: 'Ör. Annem',
                prefixIcon: Icon(Icons.label_outline),
                border: OutlineInputBorder(),
              ),
              validator: _takmaAdDogrula,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _adSoyadKontrol,
              maxLength: 100,
              textCapitalization: TextCapitalization.words, // her kelime büyük harfle başlar
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Alıcının adı soyadı',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
              validator: _adSoyadDogrula,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _ibanKontrol,
              maxLength: 32, // boşluklu yazılırsa 32 karaktere kadar çıkar
              textCapitalization: TextCapitalization.characters, // "tr" yazılsa da "TR" olur
              onFieldSubmitted: (_) => _kaydet(),
              decoration: const InputDecoration(
                labelText: 'IBAN',
                hintText: 'TR00 0000 0000 0000 0000 0000 00',
                prefixIcon: Icon(Icons.account_balance_outlined),
                border: OutlineInputBorder(),
              ),
              validator: IbanDogrulama.dogrula,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _kaydediliyor ? null : _kaydet, // null verilen buton pasif görünür
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: _kaydediliyor
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
                  : Text(_duzenlemeMi ? 'Kaydet' : 'Ekle'),
            ),
          ],
        ),
      ),
    );
  }
}