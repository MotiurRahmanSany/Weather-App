import 'package:flutter/material.dart';

class HourlyForcastItem extends StatelessWidget {
  final IconData icon;
  final String time;
  final String temperature;

  const HourlyForcastItem({
    super.key,
    required this.icon,
    required this.time,
    required this.temperature,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      child: Container(
        width: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text(
                time,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Icon(
                icon,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                '$temperature °',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
