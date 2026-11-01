import 'package:flutter/material.dart';
import 'hesaplarim_ekrani.dart';

// StatefulWidget: içinde değişen veri olan widget.
// Burada değişen veri, şifrenin gizli mi görünür mü olduğu.
class GirisEkrani extends StatefulWidget {
  const GirisEkrani({super.key});

  @override
  State<GirisEkrani> createState() => _GirisEkraniState();
}

// Adın başındaki _ işareti, bu sınıfın yalnızca bu dosyadan kullanılabileceğini belirtir.
class _GirisEkraniState extends State<GirisEkrani> {
  // Form'a erişmek ve hepsini birden doğrulamak için anahtar
  final _formAnahtari = GlobalKey<FormState>();

  // TextField'lara yazılan metni okumak için kontrolcüler
  final _epostaKontrol = TextEditingController();
  final _sifreKontrol = TextEditingController();

  bool _sifreGizli = true;

  // Ekran kapanınca kontrolcüleri bellekten temizle
  @override
  void dispose() {
    _epostaKontrol.dispose();
    _sifreKontrol.dispose();
    super.dispose();
  }

  // Doğrulayıcı: hata varsa mesajı döndürür, sorun yoksa null döndürür
  String? _epostaDogrula(String? deger) {
    final eposta = deger?.trim() ?? '';
    if (eposta.isEmpty) return 'E-posta adresinizi girin.';
    final gecerli = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(eposta);
    if (!gecerli) return 'Geçerli bir e-posta adresi girin.';
    return null;
  }

  String? _sifreDogrula(String? deger) {
    if (deger == null || deger.isEmpty) return 'Şifrenizi girin.';
    if (deger.length < 6) return 'Şifre en az 6 karakter olmalı.';
    return null;
  }

  void _girisYap() {
    // validate() bütün alanların validator'larını çalıştırır
    if (!_formAnahtari.currentState!.validate()) return;

    // TODO(2. hafta): /api/oturum/giris ile JWT alınacak
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HesaplarimEkrani()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final renkler = Theme.of(context).colorScheme;

    // Scaffold: bir ekranın temel iskeleti (gövde, üst çubuk, SnackBar alanı)
    return Scaffold(
      body: SafeArea( // çentik ve durum çubuğunun altında kalmayı önler
        child: Center(
          child: SingleChildScrollView( // klavye açılınca taşmasın, kaydırılabilsin
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formAnahtari,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch, // öğeler tam genişlikte
                children: [
                  Icon(Icons.record_voice_over, size: 64, color: renkler.primary),
                  const SizedBox(height: 12), // boşluk bırakmak için
                  const Text(
                    'Sesparator',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Sesli Bankacılık Asistanı',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // E-posta alanı
                  TextFormField(
                    controller: _epostaKontrol,
                    keyboardType: TextInputType.emailAddress, // @ işaretli klavye açılır
                    textInputAction: TextInputAction.next,    // klavyede "ileri" tuşu
                    decoration: const InputDecoration(
                      labelText: 'E-posta',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: _epostaDogrula,
                  ),
                  const SizedBox(height: 16),

                  // Şifre alanı
                  TextFormField(
                    controller: _sifreKontrol,
                    obscureText: _sifreGizli, // true ise karakterler ●●● görünür
                    onFieldSubmitted: (_) => _girisYap(), // klavyede "bitti"ye basınca
                    decoration: InputDecoration(
                      labelText: 'Şifre',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(_sifreGizli ? Icons.visibility : Icons.visibility_off),
                        // setState: "veri değişti, ekranı yeniden çiz" demek
                        onPressed: () => setState(() => _sifreGizli = !_sifreGizli),
                      ),
                    ),
                    validator: _sifreDogrula,
                  ),
                  const SizedBox(height: 24),

                  FilledButton(
                    onPressed: _girisYap,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Giriş Yap'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}