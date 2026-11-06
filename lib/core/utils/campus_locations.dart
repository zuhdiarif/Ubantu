import 'package:latlong2/latlong.dart';

class CampusLocations {
  static const LatLng defaultCenter = LatLng(-7.9526, 112.6145);

  static const LatLng ub = LatLng(-7.9526, 112.6145);
  static const LatLng polinema = LatLng(-7.9467, 112.6157);
  static const LatLng um = LatLng(-7.9622, 112.6180);
  static const LatLng suhat = LatLng(-7.9430, 112.6190);
  static const LatLng dinoyo = LatLng(-7.9480, 112.6050);
  static const LatLng sumbersari = LatLng(-7.9560, 112.6100);
  static const LatLng ketawanggede = LatLng(-7.9500, 112.6110);
  static const LatLng kerto = LatLng(-7.9535, 112.6095);
  static const LatLng mtHaryono = LatLng(-7.9490, 112.6080);
  static const LatLng watugong = LatLng(-7.9515, 112.6115);
  static const LatLng tlogomas = LatLng(-7.9350, 112.5990);
  static const LatLng matos = LatLng(-7.9565, 112.6185);
  static const LatLng stasiunMalang = LatLng(-7.9775, 112.6375);

  static LatLng? resolve(String? address) {
    if (address == null || address.trim().isEmpty) {
      return null;
    }
    final lower = address.toLowerCase();

    if (lower.contains('stasiun malang') || lower.contains('stasiun')) {
      return stasiunMalang;
    }
    if (lower.contains('matos') || lower.contains('malang town square')) {
      return matos;
    }
    if (lower.contains('polinema') ||
        lower.contains('politeknik negeri malang')) {
      return polinema;
    }
    if (lower.contains('universitas negeri malang') ||
        RegExp(r'\bum\b').hasMatch(lower)) {
      return um;
    }
    if (lower.contains('suhat') || lower.contains('soekarno hatta')) {
      return suhat;
    }
    if (lower.contains('tlogomas')) {
      return tlogomas;
    }
    if (lower.contains('dinoyo')) {
      return dinoyo;
    }
    if (lower.contains('sumbersari')) {
      return sumbersari;
    }
    if (lower.contains('ketawanggede')) {
      return ketawanggede;
    }
    if (lower.contains('kerto')) {
      return kerto;
    }
    if (lower.contains('mt haryono') || lower.contains('m.t. haryono')) {
      return mtHaryono;
    }
    if (lower.contains('watugong')) {
      return watugong;
    }
    if (lower.contains('brawijaya') ||
        lower.contains('filkom') ||
        lower.contains('ft ub') ||
        lower.contains('veteran') ||
        RegExp(r'\bub\b').hasMatch(lower)) {
      return ub;
    }

    return null;
  }
}
