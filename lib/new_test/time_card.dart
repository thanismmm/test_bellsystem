import 'package:flutter/material.dart';
import 'time_display.dart';

class TimeCard extends StatelessWidget {
  final String title;
  final TimeOfDay time;
  final VoidCallback onTimeTap;

  const TimeCard({
    super.key,
    required this.title,
    required this.time,
    required this.onTimeTap,
  });

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
        onTap: onTimeTap,
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
              TimeDisplay(time: time),
              IconButton(
                icon: Icon(Icons.access_time, color: Colors.blue[700]),
                onPressed: onTimeTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}