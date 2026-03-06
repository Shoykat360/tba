import 'package:flutter/material.dart';

class AttendanceActionButton extends StatelessWidget {
  final bool canMarkAttendance;
  final bool isLoading;
  final VoidCallback? onPressed;

  const AttendanceActionButton({
    super.key,
    required this.canMarkAttendance,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        child: ElevatedButton.icon(
          onPressed: canMarkAttendance && !isLoading ? onPressed : null,
          icon: isLoading
              ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: theme.colorScheme.onPrimary,
            ),
          )
              : const Icon(Icons.fingerprint_rounded, size: 24),
          label: Text(
            isLoading ? 'Marking...' : 'Mark Attendance',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: canMarkAttendance
                ? Colors.green
                : theme.colorScheme.surfaceVariant,
            foregroundColor: canMarkAttendance
                ? Colors.white
                : theme.colorScheme.onSurfaceVariant,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: canMarkAttendance ? 2 : 0,
          ),
        ),
      ),
    );
  }
}