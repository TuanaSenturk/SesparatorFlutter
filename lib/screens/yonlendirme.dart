import 'package:flutter/material.dart';

import '../models/oturum.dart';
import 'musteri_ana_ekrani.dart';
import 'yonetici_ana_ekrani.dart';

/// Oturumdaki role göre gidilecek ana ekran.
Widget anaEkran(Oturum oturum) {
  return oturum.yoneticiMi
      ? YoneticiAnaEkrani(oturum: oturum)
      : MusteriAnaEkrani(oturum: oturum);
}