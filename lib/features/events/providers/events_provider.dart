import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/events_repository.dart';
import '../data/events_models.dart';

final eventsRepositoryProvider = Provider((ref) => EventsRepository());

final selectedEventCategoryProvider = StateProvider<String?>((ref) => null);

final eventsProvider = FutureProvider<List<Event>>((ref) async {
  final category = ref.watch(selectedEventCategoryProvider);
  return ref.read(eventsRepositoryProvider).getEvents(category: category);
});

final upcomingEventsProvider = FutureProvider<List<Event>>((ref) async {
  return ref.read(eventsRepositoryProvider).getEvents(upcoming: true);
});
