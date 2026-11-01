class ApiAyarlari {
  // Emülatörde 10.0.2.2 = bilgisayarın localhost'u.
  // (Emülatörün içinde "localhost" emülatörün kendisi demektir.)
  // Farklı adres için: flutter run --dart-define=API_ADRESI=http://192.168.1.20:5231
  static const String tabanAdres = String.fromEnvironment(
    'API_ADRESI',
    defaultValue: 'http://10.0.2.2:5231',
  );

  static const Duration zamanAsimi = Duration(seconds: 10);
}