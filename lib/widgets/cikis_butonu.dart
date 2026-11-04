import 'package:flutter/material.dart';

import '../screens/giris_ekrani.dart';
import '../services/oturum_servisi.dart';

/// Üst çubuktaki çıkış düğmesi. Onay sorar, oturumu siler ve girişe döner.
class CikisButonu extends StatelessWidget {
  const CikisButonu({super.key});

  Future<void> _cikisYap(BuildContext context) async {
    // showDialog bir Future döndürür: kullanıcının seçimi (true/false) ya da dışarı dokunursa null
    final onay = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çıkış yap'),
        content: const Text('Oturumunuzu kapatmak istiyor musunuz?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Vazgeç')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Çıkış yap')),
        ],
      ),
    );
    if (onay != true) return;

    await OturumServisi().cikisYap(); // telefondaki token silinir
    if (!context.mounted) return;

    // Bütün ekran yığınını temizleyip girişi aç: geri tuşuyla oturuma dönülemez
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const GirisEkrani()),
          (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Çıkış yap',
      icon: const Icon(Icons.logout),
      onPressed: () => _cikisYap(context),
    );
  }
}