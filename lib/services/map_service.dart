import 'dart:math';
import 'package:latlong2/latlong.dart';

class MapService {
  /// Calculate Haversine distance in kilometers between two coordinates
  static double calculateDistanceKm(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295; // Math.PI / 180
    final a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }

  /// Generate intermediate curved polyline points between two points for scenic map display
  static List<LatLng> generateRouteCurve(LatLng start, LatLng end, {int segments = 20}) {
    final List<LatLng> points = [];
    final midLat = (start.latitude + end.latitude) / 2 + (sin((start.longitude - end.longitude) * 2) * 0.02);
    final midLng = (start.longitude + end.longitude) / 2 + (cos((start.latitude - end.latitude) * 2) * 0.02);
    final mid = LatLng(midLat, midLng);

    for (int i = 0; i <= segments; i++) {
      final t = i / segments;
      // Quadratic Bezier interpolation
      final lat = (1 - t) * (1 - t) * start.latitude + 2 * (1 - t) * t * mid.latitude + t * t * end.latitude;
      final lng = (1 - t) * (1 - t) * start.longitude + 2 * (1 - t) * t * mid.longitude + t * t * end.longitude;
      points.add(LatLng(lat, lng));
    }
    return points;
  }
}
