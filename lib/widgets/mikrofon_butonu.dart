import 'dart:async';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../services/api_servisi.dart';
import '../services/ses_kaydedici.dart';
import '../services/ses_servisi.dart';

/// Dokun-konuş: ilk dokunuşta kaydı başlatır, ikincide durdurup metne çevirir ve onMetin ile verir.
class MikrofonButonu extends StatefulWidget {
  const MikrofonButonu({
    super.key,
    required this.onMetin,
    required this.onHata,
    this.onDurumDegisti,
    this.aktif = true,
  });

  final ValueChanged<String> onMetin;       // algılanan metin
  final ValueChanged<String> onHata;        // izin / bağlantı / anlaşılamadı mesajı
  final ValueChanged<bool>? onDurumDegisti; // dinleniyor mu? (gösterge için)
  final bool aktif;                         // asistan yanıt beklerken false

  @override
  State<MikrofonButonu> createState() => _MikrofonButonuState();
}

class _MikrofonButonuState extends State<MikrofonButonu> {
  static const _enUzunKayit = Duration(seconds: 30); // 2 MB sunucu sınırının altında kalsın
  static const _enKisaKayit = Duration(milliseconds: 500); // altı yanlışlıkla çift dokunma sayılır

  final _kaydedici = SesKaydedici();
  final _sesServisi = SesServisi();

  bool _izinBekleniyor = false; // izin penceresi açıkken ikinci dokunuşu yok say
  Future<void>? _baslatma;  // null değilse kayıt başlatıldı
  DateTime? _baslangic;
  Timer? _zamanlayici;
  bool _dinleniyor = false;
  bool _gonderiliyor = false;

  @override
  void dispose() {
    _zamanlayici?.cancel();
    _kaydedici.dispose();
    super.dispose();
  }

  /// Kayıt yoksa başlatır, varsa durdurup gönderir
  void _dokunuldu() {
    if (_baslatma != null) {
      _bitir();
    } else {
      _basla();
    }
  }

  Future<void> _basla() async {
    if (!widget.aktif || _gonderiliyor || _izinBekleniyor) return;

    _izinBekleniyor = true;
    final izin = await _kaydedici.izinIste();
    _izinBekleniyor = false;
    if (!izin.isGranted) {
      if (izin.isPermanentlyDenied) {
        widget.onHata('Mikrofon izni kapalı. Açılan ayarlardan izin verin.');
        await openAppSettings();
      } else {
        widget.onHata('Mikrofon izni verilmedi.');
      }
      return;
    }
    if (!mounted) return;

    _baslangic = DateTime.now();
    _baslatma = _kaydedici.baslat();
    _zamanlayici = Timer(_enUzunKayit, _bitir);
    setState(() {
      _dinleniyor = true;
    });
    widget.onDurumDegisti?.call(true);
  }

  Future<void> _bitir() async {
    final baslatma = _baslatma;
    if (baslatma == null) return; // kayıt hiç başlamadı
    _baslatma = null;
    _zamanlayici?.cancel();

    if (mounted) {
      setState(() {
        _dinleniyor = false;
      });
    }
    widget.onDurumDegisti?.call(false);

    try {
      await baslatma; // hızlı bırakılırsa önce başlatmanın bitmesini bekle
    } catch (_) {
      widget.onHata('Kayıt başlatılamadı.');
      return;
    }

    if (DateTime.now().difference(_baslangic!) < _enKisaKayit) {
      await _kaydedici.iptal();
      return;
    }

    final yol = await _kaydedici.durdur();
    if (yol == null || !mounted) return;

    setState(() {
      _gonderiliyor = true;
    });
    try {
      widget.onMetin(await _sesServisi.metneCevir(yol));
    } on ApiHatasi catch (e) {
      widget.onHata(e.mesaj);
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
    final renkler = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: _dokunuldu,
      child: CircleAvatar(
        radius: 24,
        backgroundColor: _dinleniyor ? renkler.error : renkler.secondaryContainer,
        child: _gonderiliyor
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : Icon(
                _dinleniyor ? Icons.mic : Icons.mic_none,
                color: _dinleniyor ? renkler.onError : renkler.onSecondaryContainer,
              ),
      ),
    );
  }
}
