/// IBAN temizleme ve doğrulama. Sunucudaki IbanYardimcisi ile aynı kural.
class IbanDogrulama {
  /// "tr33 0006 1005 ..." -> "TR330006100519786457841326"
  static String temizle(String iban) => iban.replaceAll(' ', '').toUpperCase();

  /// Form doğrulayıcısı: hata varsa mesaj, geçerliyse null döndürür.
  static String? dogrula(String? deger) {
    final iban = temizle(deger ?? '');
    if (iban.isEmpty) return 'IBAN zorunludur.';
    if (!RegExp(r'^TR\d{24}$').hasMatch(iban)) {
      return 'IBAN, TR ile başlayıp 24 rakamla devam etmelidir.';
    }

    // Mod 97: ilk 4 karakter sona alınır, T=29 R=27 yazılır, kalan 1 olmalı.
    // Sayı çok büyük olduğu için rakam rakam ilerleyip sadece kalanı tutuyoruz.
    final sayi = '${iban.substring(4)}2927${iban.substring(2, 4)}';
    var kalan = 0;
    for (final rakam in sayi.split('')) {
      kalan = (kalan * 10 + int.parse(rakam)) % 97;
    }
    if (kalan != 1) return 'IBAN hatalı görünüyor, lütfen rakamları kontrol edin.';
    return null;
  }
}