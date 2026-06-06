import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/notices_repository.dart';
import '../data/notices_models.dart';

final noticesRepositoryProvider = Provider((ref) => NoticesRepository());

final selectedNoticeCategoryProvider = StateProvider<String?>((ref) => null);

final noticesProvider = FutureProvider<List<Notice>>((ref) async {
  final category = ref.watch(selectedNoticeCategoryProvider);
  
  // Normalize the category string to lowercase to match the Django DB records cleanly
  final backendCategory = category?.toLowerCase();
  
  return ref.read(noticesRepositoryProvider).getNotices(category: backendCategory);
});
