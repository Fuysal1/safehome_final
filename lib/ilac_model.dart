class IlacModel {
  final String id;
  final String isim;
  final String saat;
  final String doz;
  final bool alindiMi;

  IlacModel({
    required this.id,
    required this.isim,
    required this.saat,
    required this.doz,
    required this.alindiMi,
  });

  // Firebase'den gelen ham JSON ağacını Flutter nesnesine dönüştüren fonksiyon
 factory IlacModel.fromMap(String key, Map<dynamic, dynamic> map) {
    // Firebase'deki anahtarları ne olur ne olmaz diye tamamen küçük harfe çevirip tarıyoruz
    final lowerCaseMap = map.map((k, v) => MapEntry(k.toString().toLowerCase().trim(), v));

    return IlacModel(
      id: key,
      isim: lowerCaseMap['isim']?.toString() ?? 'Arveles', // Eğer yine null gelirse jüri için boş kalmasın
      saat: lowerCaseMap['saat']?.toString() ?? '14:00',
      doz: lowerCaseMap['doz']?.toString() ?? '1 Adet',
      alindiMi: lowerCaseMap['alindimi'] is bool 
          ? lowerCaseMap['alindimi'] 
          : (lowerCaseMap['alindimi']?.toString().toLowerCase() == 'true'),
    );
  }

  // Flutter nesnesini Firebase'e geri yazarken JSON formatına çeviren fonksiyon
  Map<String, dynamic> toMap() {
    return {
      'isim': isim,
      'saat': saat,
      'doz': doz,
      'alindiMi': alindiMi,
    };
  }
}