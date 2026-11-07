import 'package:flutter/material.dart';

/// Bağlantı/sunucu hatasında mesaj ve "Tekrar dene" düğmesi gösterir.
/// Hesaplarım ve hesap detay ekranları ortak kullanır.
class HataGorunumu extends StatelessWidget {
  const HataGorunumu({super.key, required this.mesaj, required this.onTekrarDene});

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
