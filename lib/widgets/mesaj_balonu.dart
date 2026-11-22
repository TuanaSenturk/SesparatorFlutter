import 'package:flutter/material.dart';

import '../models/asistan_yaniti.dart';
import '../models/sohbet_mesaji.dart';
import '../utils/bicim.dart';

/// Sohbetteki tek bir mesaj: kullanıcınınki sağda, asistanınki solda.
class MesajBalonu extends StatelessWidget {
  const MesajBalonu({super.key, required this.mesaj});

  final SohbetMesaji mesaj;

  @override
  Widget build(BuildContext context) {
    final renkler = Theme.of(context).colorScheme;
    final kullanici = mesaj.kullanicidanMi;

    // Renkler temadan gelir: kullanıcı / asistan / hata
    final Color arkaPlan;
    final Color yazi;
    if (mesaj.hata) {
      arkaPlan = renkler.errorContainer;
      yazi = renkler.onErrorContainer;
    } else if (kullanici) {
      arkaPlan = renkler.primary;
      yazi = renkler.onPrimary;
    } else {
      arkaPlan = renkler.surfaceContainerHighest;
      yazi = renkler.onSurface;
    }

    // Konuşma tarafındaki alt köşe küçük: balonun kimden geldiği belli olsun
    const buyuk = Radius.circular(16);
    const kucuk = Radius.circular(4);
    final kose = BorderRadius.only(
      topLeft: buyuk,
      topRight: buyuk,
      bottomLeft: kullanici ? buyuk : kucuk,
      bottomRight: kullanici ? kucuk : buyuk,
    );

    return Align(
      alignment: kullanici ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        // Uzun mesajlar ekranın tamamına yayılmasın
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.78),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
          decoration: BoxDecoration(color: arkaPlan, borderRadius: kose),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (mesaj.hata)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.error_outline, size: 18, color: yazi),
                ),
              Text(mesaj.metin, style: TextStyle(color: yazi, fontSize: 15)),
              if (mesaj.bekleyenTransfer != null) _TransferKarti(transfer: mesaj.bekleyenTransfer!),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  Bicim.saat(mesaj.zaman),
                  style: TextStyle(color: yazi.withValues(alpha: 0.7), fontSize: 11),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Onay bekleyen transferin özeti (alıcı, IBAN, tutar)
class _TransferKarti extends StatelessWidget {
  const _TransferKarti({required this.transfer});

  final BekleyenTransfer transfer;

  @override
  Widget build(BuildContext context) {
    final renkler = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(top: 8),
      color: renkler.surface,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(transfer.aliciAdSoyad, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(Bicim.iban(transfer.aliciIban), style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 8),
            Text(
              Bicim.para(transfer.tutar),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: renkler.primary),
            ),
            const SizedBox(height: 8),
            Text(
              "Onaylamak için 'evet', iptal için 'vazgeç' yazın.",
              style: TextStyle(fontSize: 12, color: renkler.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
