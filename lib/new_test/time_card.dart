import 'package:flutter/material.dart';
import 'time_display.dart';

class TimeCard extends StatelessWidget {
  final String title;
  final TimeOfDay? time;
  final VoidCallback onTimeTap;
  final bool enabled;
  final ValueChanged<bool> onToggle;

  const TimeCard({
    Key? key,
    required this.title,
    required this.time,
    required this.onTimeTap,
    required this.enabled,
    required this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.blue[100]!, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: enabled ? onTimeTap : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              // Toggle switch moved here (left of time display)
              Switch(
                value: enabled,
                onChanged: onToggle,
                activeColor: Colors.blue[700],
              ),
              const SizedBox(width: 8),
              // Show time or "disable" text
              enabled && time != null
                  ? TimeDisplay(time: time!)
                  : const Text(
                      'disabled',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
              IconButton(
                icon: Icon(
                  Icons.access_time,
                  color: enabled ? Colors.blue[700] : Colors.grey,
                ),
                onPressed: enabled ? onTimeTap : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
