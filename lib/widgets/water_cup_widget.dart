import 'package:flutter/material.dart';

class WaterCupWidget extends StatelessWidget {
  final String label;
  final double amount;
  final String unit;
  final VoidCallback onTap;
  final bool isSelected;

  const WaterCupWidget({
    super.key,
    required this.label,
    required this.amount,
    this.unit = 'ml',
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFE8EAF6) // light indigo
              : Colors.white,
          border: Border.all(
            color: isSelected
                ? const Color(0xFF2962FF) // vibrant blue
                : const Color(0xFFE0E7FF), // light indigo border
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.water_drop,
              size: 40,
              color: isSelected
                  ? const Color(0xFF2962FF) // vibrant blue
                  : const Color(0xFF448AFF), // bright blue
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${amount.toStringAsFixed(0)} $unit',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF3F51B5), // medium indigo
              ),
            ),
          ],
        ),
      ),
    );
  }
}
