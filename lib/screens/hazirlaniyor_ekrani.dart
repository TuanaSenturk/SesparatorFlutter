import 'package:flutter/material.dart';

import '../widgets/cikis_butonu.dart';

/// İçeriği sonraki haftalarda eklenecek sekmeler için ortak ekran.
class HazirlaniyorEkrani extends StatelessWidget {
  const HazirlaniyorEkrani({
    super.key,
    required this.baslik,
    required this.ikon,
    required this.aciklama,
  });

  final String baslik;
  final IconData ikon;
  final String aciklama;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(baslik), actions: const [CikisButonu()]),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(ikon, size: 64, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 12),
              Text(aciklama, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}