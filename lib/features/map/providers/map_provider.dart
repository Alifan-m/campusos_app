import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/map_repository.dart';
import '../data/map_models.dart';

final mapRepositoryProvider = Provider((ref) => MapRepository());

final mapLocationsProvider = FutureProvider<List<MapLocation>>((ref) async {
  return ref.read(mapRepositoryProvider).getLocations();
});

final mapSearchProvider = StateProvider<String>((ref) => '');
