import 'package:flutter/material.dart';
import 'time_display.dart';

class TimeCard extends StatelessWidget {
  final String title;
  final TimeOfDay? time;
  final VoidCallback onTimeTap;
  final bool enabled;
  final ValueChanged onToggle;
  final VoidCallback onEditTitle;

  const TimeCard({
    super.key,
    required this.title,
    required this.time,
    required this.onTimeTap,
    required this.enabled,
    required this.onToggle,
    required this.onEditTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: enabled ? Colors.white : Colors.grey[300],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.blue[100]!, width: 1),
      ),
      child: Row(
        children: [
          // Expanded area for title and background tap
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onEditTitle,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 5),
          // Only the time label is tappable for time picking
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: enabled ? onTimeTap : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
              child: enabled && time != null
                  ? TimeDisplay(time: time!)
                  : const Text(
                      'disabled',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: enabled,
            onChanged: onToggle,
            activeColor: Colors.blue[700],
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}
