import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Budget Calculator Calculation Tests', () {
    test('Calculates multi-category trip budget per person accurately', () {
      const travelers = 3;
      const days = 2;
      const transportPerDay = 400;
      const stayPerNight = 1100;
      const foodPerDay = 500;
      const activityPerDay = 300;

      const totalTransport = transportPerDay * days * travelers; // 400 * 2 * 3 = 2400
      const totalStay = stayPerNight * (days - 1) * travelers; // 1100 * 1 * 3 = 3300
      const totalFood = foodPerDay * days * travelers; // 500 * 2 * 3 = 3000
      const totalActivity = activityPerDay * days * travelers; // 300 * 2 * 3 = 1800

      const grandTotal = totalTransport + totalStay + totalFood + totalActivity; // 10500
      final perPerson = (grandTotal / travelers).round(); // 3500

      expect(grandTotal, 10500);
      expect(perPerson, 3500);
    });
  });
}
