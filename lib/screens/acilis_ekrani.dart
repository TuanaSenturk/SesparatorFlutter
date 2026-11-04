import 'package:flutter/material.dart';

import '../services/oturum_servisi.dart';
import 'giris_ekrani.dart';
import 'yonlendirme.dart';

/// Uygulama açılınca ilk görünen ekran. Kayıtlı oturumu kontrol edip yönlendirir.
class AcilisEkrani extends StatefulWidget {
  const AcilisEkrani({super.key});

  @override
  State<AcilisEkrani> createState() => _AcilisEkraniState();
}

class _AcilisEkraniState extends State<AcilisEkrani> {
  @override
  void initState() {
    super.initState();
    _oturumuKontrolEt();
  }

  Future<void> _oturumuKontrolEt() async {
    // Güvenli depodan okumak kısa bir süre alır; bu sırada dönen gösterge görünür
    final oturum = await OturumServisi().kayitliOturum();
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        // Oturum yoksa ya da süresi dolduysa giriş, varsa role göre ana ekran
        builder: (_) => oturum == null ? const GirisEkrani() : anaEkran(oturum),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}