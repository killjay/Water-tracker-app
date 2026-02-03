import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 150),
      opacity: enabled ? 1.0 : 0.6,
      child: SizedBox(
        height: 50,
        child: ElevatedButton(
          onPressed: enabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: enabled
                ? const Color(0xFFE2F163) // lime green
                : const Color(0xFF1C1C1E), // disabled background
            foregroundColor: enabled
                ? const Color(0xFF000000) // black text
                : const Color(0x99EBEBF5), // disabled text
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
          child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF000000),
                    ),
                  ),
                )
              : Text(
                  label,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                  ),
                ),
        ),
      ),
    );
  }
}

