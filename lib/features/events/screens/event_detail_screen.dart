import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/events_provider.dart';
import '../data/events_repository.dart';
import '../data/events_models.dart';

class EventDetailScreen extends ConsumerStatefulWidget {
  final int eventId;
  const EventDetailScreen({super.key, required this.eventId});

  @override
  ConsumerState<EventDetailScreen> createState() =>
      _EventDetailScreenState();
}

class _EventDetailScreenState extends ConsumerState<EventDetailScreen> {
  Event? _event;
  bool _loading = true;
  bool _rsvpLoading = false;

  @override
  void initState() {
    super.initState();
    _loadEvent();
  }

  Future<void> _loadEvent() async {
    try {
      final event = await ref
          .read(eventsRepositoryProvider)
          .getEvent(widget.eventId);
      setState(() {
        _event = event;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _toggleRsvp() async {
    if (_event == null) return;
    setState(() => _rsvpLoading = true);
    try {
      await ref
          .read(eventsRepositoryProvider)
          .toggleRsvp(_event!.id);
      await _loadEvent();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not update RSVP')),
        );
      }
    }
    setState(() => _rsvpLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Event Details',
            style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _event == null
              ? const Center(child: Text('Event not found'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category + Today badge
                      Row(
                        children: [
                          if (_event!.category != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _event!.category!,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          if (_event!.isToday) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'TODAY',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 16),

                      Text(
                        _event!.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.onSurface,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Info cards
                      _InfoRow(
                        icon: Icons.calendar_today_rounded,
                        label: 'Date',
                        value: _formatDate(_event!.startDate),
                      ),
                      _InfoRow(
                        icon: Icons.access_time_rounded,
                        label: 'Time',
                        value:
                            '${_formatTime(_event!.startDate)} — ${_formatTime(_event!.endDate)}',
                      ),
                      if (_event!.location != null)
                        _InfoRow(
                          icon: Icons.location_on_outlined,
                          label: 'Location',
                          value: _event!.location!,
                        ),
                      _InfoRow(
                        icon: Icons.people_outline,
                        label: 'Attending',
                        value: '${_event!.rsvpCount} people',
                      ),

                      const SizedBox(height: 24),
                      const Text(
                        'About this event',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _event!.description,
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.onSurfaceVariant,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // RSVP button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: _event!.isRsvped
                            ? OutlinedButton.icon(
                                onPressed:
                                    _rsvpLoading ? null : _toggleRsvp,
                                icon: const Icon(Icons.check_circle_rounded),
                                label: _rsvpLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      )
                                    : const Text('You\'re going · Cancel RSVP'),
                              )
                            : ElevatedButton.icon(
                                onPressed:
                                    _rsvpLoading ? null : _toggleRsvp,
                                icon: const Icon(Icons.how_to_reg_rounded),
                                label: _rsvpLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                        ),
                                      )
                                    : const Text('RSVP — I\'m going'),
                              ),
                      ),
                    ],
                  ),
                ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday'
    ];
    return '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : hour == 0 ? 12 : hour;
    return '$displayHour:$minute $period';
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.onSurfaceVariant)),
              Text(value,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface)),
            ],
          ),
        ],
      ),
    );
  }
}
