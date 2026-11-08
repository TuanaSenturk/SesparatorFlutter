import 'package:flutter/material.dart';

import '../models/kayitli_alici.dart';
import '../services/api_servisi.dart';
import '../services/kayitli_alici_servisi.dart';
import '../utils/bicim.dart';
import '../widgets/hata_gorunumu.dart';
import 'kayitli_alici_form_ekrani.dart';

/// Kayıtlı alıcılar: listeleme, ekleme/düzenleme (form) ve kaydırarak silme.
class KayitliAlicilarEkrani extends StatefulWidget {
  const KayitliAlicilarEkrani({super.key});

  @override
  State<KayitliAlicilarEkrani> createState() => _KayitliAlicilarEkraniState();
}

class _KayitliAlicilarEkraniState extends State<KayitliAlicilarEkrani> {
  final _servis = KayitliAliciServisi();
  late Future<List<KayitliAlici>> _alicilar;

  @override
  void initState() {
    super.initState();
    _alicilar = _servis.listele();
  }

  // Hesaplarım'daki _yenile ile aynı mantık
  Future<void> _yenile() async {
    final yeni = _servis.listele();
    setState(() => _alicilar = yeni);
    try {
      await yeni;
    } catch (_) {
      // Hata FutureBuilder tarafından ekranda gösterilir
    }
  }

  /// alici null: ekleme, dolu: düzenleme
  Future<void> _formuAc([KayitliAlici? alici]) async {
    final kaydedildi = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => KayitliAliciFormEkrani(alici: alici)),
    );
    if (kaydedildi != true) return; // geri tuşuyla çıkıldıysa bir şey yapma

    await _yenile();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(alici == null ? 'Alıcı eklendi.' : 'Alıcı güncellendi.')),
    );
  }

  /// Dismissible kaydırılınca çağrılır. true dönerse satır silinir, false dönerse geri gelir.
  Future<bool> _silmeyiOnayla(KayitliAlici alici) async {
    final onay = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alıcıyı sil'),
        content: Text('"${alici.takmaAd}" kayıtlı alıcılarınızdan silinsin mi?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Vazgeç')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sil')),
        ],
      ),
    );
    if (onay != true) return false;

    // Önce sunucudan sil; başarısız olursa satır ekranda kalsın
    try {
      await _servis.sil(alici.id);
      return true;
    } on ApiHatasi catch (hata) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(hata.mesaj)));
      }
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kayıtlı Alıcılar')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _formuAc(),
        icon: const Icon(Icons.person_add),
        label: const Text('Alıcı ekle'),
      ),
      body: FutureBuilder<List<KayitliAlici>>(
        future: _alicilar,
        builder: (context, durum) {
          // Sadece ilk yüklemede tam ekran gösterge
          if (durum.connectionState != ConnectionState.done && !durum.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (durum.hasError) {
            return HataGorunumu(mesaj: '${durum.error}', onTekrarDene: _yenile);
          }
          final alicilar = durum.data ?? [];
          if (alicilar.isEmpty) {
            return const Center(
              child: Text('Henüz kayıtlı alıcınız yok.\n"Alıcı ekle" ile ekleyebilirsiniz.',
                  textAlign: TextAlign.center),
            );
          }
          return RefreshIndicator(
            onRefresh: _yenile,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 88), // son satır butonun altında kalmasın
              itemCount: alicilar.length,
              itemBuilder: (context, i) {
                final alici = alicilar[i];
                // Dismissible: satırı yana kaydırarak silmeyi sağlar
                return Dismissible(
                  key: ValueKey(alici.id), // her satırı ayırt eden benzersiz anahtar
                  direction: DismissDirection.endToStart, // sadece sağdan sola
                  background: Container(
                    color: Theme.of(context).colorScheme.error,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (_) => _silmeyiOnayla(alici),
                  onDismissed: (_) {
                    // Silinen satır listeden de çıkmalı, yoksa Flutter hata verir
                    setState(() => alicilar.remove(alici));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${alici.takmaAd} silindi.')),
                    );
                  },
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      child: Text(alici.takmaAd[0].toUpperCase()),
                    ),
                    title: Text(alici.takmaAd, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('${alici.adSoyad}\n${Bicim.iban(alici.iban)}'),
                    isThreeLine: true,
                    trailing: const Icon(Icons.edit_outlined),
                    onTap: () => _formuAc(alici), // dokununca düzenleme formu
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
/*
Listeleme: FutureBuilder, HataGorunumu ve aşağı çekip yenileme Hesaplarım ekranındakiyle aynı. IBAN, Bicim.iban ile 4'erli
gruplar hâlinde gösterilir.
Silme: confirmDismiss önce onay sorar, sonra DELETE atar. Sunucu hata verirse false döner ve satır geri gelir. Böylece ek-
randa silinmiş görünüp veritabanında duran bir kayıt kalmaz.
onDismissed: Satırı listeden de çıkarır. Bunu yapmazsan Flutter “A dismissed Dismissible widget is still part of the tree”
hatası verir.
Ekleme ve düzenleme: “Alıcı ekle” butonu boş formu, satıra dokunmak dolu formu açar.
 */