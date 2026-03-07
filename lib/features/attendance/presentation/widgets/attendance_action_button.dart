import 'package:flutter/material.dart';

class AttendanceActionButton extends StatelessWidget {
  final bool canMarkAttendance;
  final bool isLoading;
  final VoidCallback onPressed;

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
      height: 52,
      child: ElevatedButton(
        onPressed: canMarkAttendance && !isLoading ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: canMarkAttendance
              ? Colors.green
              : theme.colorScheme.surfaceVariant,
          foregroundColor: canMarkAttendance
              ? Colors.white
              : theme.colorScheme.onSurfaceVariant,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: canMarkAttendance ? 2 : 0,
        ),
        child: isLoading
            ? const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2.5,
          ),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              canMarkAttendance
                  ? Icons.check_circle_outline_rounded
                  : Icons.lock_outline_rounded,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Mark Attendance',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: canMarkAttendance
                    ? Colors.white
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}