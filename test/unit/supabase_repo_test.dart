import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pune_explorer/core/supabase/supabase_config.dart';
import 'package:pune_explorer/data/repositories/supabase/supabase_destination_repository.dart';
import 'package:pune_explorer/data/models/destination.dart';
import 'package:pune_explorer/core/enums/app_enums.dart';

class _RealHttpOverrides extends HttpOverrides {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = _RealHttpOverrides();
  SharedPreferences.setMockInitialValues({});

  test('SupabaseDestinationRepository live integration test', () async {
    final ok = await SupabaseConfig.initialize();
    print('Supabase initialized: $ok');
    expect(ok, isTrue);

    final repo = SupabaseDestinationRepository();
    final initialList = await repo.getDestinations();
    print('Initial fetched ${initialList.length} destinations from repo');

    // Test adding a destination
    final testDest = Destination(
      id: 'test_dest_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Integration Test Destination',
      city: 'Pune',
      state: 'Maharashtra',
      category: DestinationCategory.forts,
      description: 'Short test description',
      longDescription: 'Long test description',
      images: const ['https://example.com/test.jpg'],
      rating: 4.5,
      reviewCount: 10,
      latitude: 18.52,
      longitude: 73.85,
      entryFeeIndian: 25.0,
      entryFeeForeign: 250.0,
      bestTime: 'October',
      openingHours: '9am - 5pm',
      recommendedDuration: '2 hours',
      famousFor: 'Testing',
      difficulty: DifficultyLevel.easy,
      distanceFromPuneKm: 10.0,
      isTrending: true,
      isFeatured: true,
    );

    print('Adding destination ${testDest.id}...');
    await repo.addDestination(testDest);
    print('Destination added successfully!');

    // Test reading back
    final fetched = await repo.getDestinationById(testDest.id);
    print('Fetched back: ${fetched?.name}');
    expect(fetched, isNotNull);
    expect(fetched!.name, equals(testDest.name));

    // Verify it appears in getDestinations()
    final updatedList = await repo.getDestinations();
    expect(updatedList.any((d) => d.id == testDest.id), isTrue);

    // Test deleting
    print('Deleting destination ${testDest.id}...');
    await repo.deleteDestination(testDest.id);
    print('Destination deleted successfully!');

    // Verify it is permanently gone and returns null
    final deletedCheck = await repo.getDestinationById(testDest.id);
    expect(deletedCheck, isNull);
    final finalList = await repo.getDestinations();
    expect(finalList.any((d) => d.id == testDest.id), isFalse);
    print('Verified: Destination is permanently deleted and returns null.');
  });
}
