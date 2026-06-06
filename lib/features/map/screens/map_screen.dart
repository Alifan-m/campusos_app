import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/map_provider.dart';
import '../data/map_models.dart';

class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  static const String _mapImageUrl =
      'https://res.cloudinary.com/dpuwsaxji/image/upload/v1780778338/Screenshot_from_2026-06-06_23-33-25_dbxj58.png';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationsAsync = ref.watch(mapLocationsProvider);
    final search = ref.watch(mapSearchProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Campus Map',
            style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            color: AppColors.surfaceContainerLowest,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              onChanged: (v) =>
                  ref.read(mapSearchProvider.notifier).state = v,
              decoration: InputDecoration(
                hintText: 'Search locations...',
                prefixIcon: const Icon(Icons.search, size: 20),
                filled: true,
                fillColor: AppColors.surfaceContainerHigh,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),

          // Map
          Expanded(
            child: locationsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.map_outlined,
                        size: 64, color: AppColors.outline),
                    const SizedBox(height: 16),
                    const Text('Could not load map',
                        style:
                            TextStyle(color: AppColors.onSurfaceVariant)),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => ref.refresh(mapLocationsProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (locations) {
                final filtered = search.isEmpty
                    ? locations
                    : locations
                        .where((l) => l.name
                            .toLowerCase()
                            .contains(search.toLowerCase()))
                        .toList();

                return InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Stack(
                    children: [
                      // Map image
                      Image.network(
                        _mapImageUrl,
                        fit: BoxFit.contain,
                        width: double.infinity,
                        height: double.infinity,
                        loadingBuilder: (_, child, progress) {
                          if (progress == null) return child;
                          return const Center(
                              child: CircularProgressIndicator());
                        },
                        errorBuilder: (_, __, ___) => const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.broken_image_outlined,
                                  size: 64, color: AppColors.outline),
                              SizedBox(height: 8),
                              Text('Map image failed to load',
                                  style: TextStyle(
                                      color: AppColors.onSurfaceVariant)),
                            ],
                          ),
                        ),
                      ),

                      // Pins
                      ...filtered.map((loc) => FractionallySizedBox(
                            widthFactor: loc.locationX,
                            heightFactor: loc.locationY,
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: GestureDetector(
                                onTap: () =>
                                    _showLocationSheet(context, loc),
                                child: _Pin(type: loc.locationType),
                              ),
                            ),
                          )),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showLocationSheet(BuildContext context, MapLocation location) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _typeColor(location.locationType)
                        .withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _typeIcon(location.locationType),
                    color: _typeColor(location.locationType),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        location.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                      ),
                      Text(
                        location.locationType.replaceAll('_', ' ').toUpperCase(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (location.description != null &&
                location.description!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                location.description!,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'cafeteria':
        return const Color(0xFFFF6B35);
      case 'library':
        return AppColors.primary;
      case 'lecture_hall':
        return const Color(0xFF8B5CF6);
      case 'admin':
        return const Color(0xFF10B981);
      case 'sports':
        return const Color(0xFFF59E0B);
      default:
        return AppColors.onSurfaceVariant;
    }
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'cafeteria':
        return Icons.restaurant_rounded;
      case 'library':
        return Icons.local_library_rounded;
      case 'lecture_hall':
        return Icons.school_rounded;
      case 'admin':
        return Icons.business_rounded;
      case 'sports':
        return Icons.sports_soccer_rounded;
      default:
        return Icons.location_on_rounded;
    }
  }
}

class _Pin extends StatelessWidget {
  final String type;
  const _Pin({required this.type});

  Color get color {
    switch (type) {
      case 'cafeteria':
        return const Color(0xFFFF6B35);
      case 'library':
        return AppColors.primary;
      case 'lecture_hall':
        return const Color(0xFF8B5CF6);
      case 'admin':
        return const Color(0xFF10B981);
      case 'sports':
        return const Color(0xFFF59E0B);
      default:
        return AppColors.onSurfaceVariant;
    }
  }

  IconData get icon {
    switch (type) {
      case 'cafeteria':
        return Icons.restaurant_rounded;
      case 'library':
        return Icons.local_library_rounded;
      case 'lecture_hall':
        return Icons.school_rounded;
      case 'admin':
        return Icons.business_rounded;
      case 'sports':
        return Icons.sports_soccer_rounded;
      default:
        return Icons.location_on_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        CustomPaint(
          size: const Size(12, 6),
          painter: _TrianglePainter(color: color),
        ),
      ],
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  const _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}
