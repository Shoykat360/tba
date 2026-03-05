/*
import 'package:flutter/material.dart';

class AttendanceActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final bool hasMarkedAttendance;

  const AttendanceActionButton({
    super.key,
    required this.onPressed,
    required this.isLoading,
    required this.isEnabled,
    required this.hasMarkedAttendance,
  });

  String _buildButtonLabel() {
    if (hasMarkedAttendance) return 'Attendance Marked ✓';
    if (!isEnabled) return 'Move Closer to Mark Attendance';
    return 'Mark Attendance';
  }

  Color _buildBackgroundColor(BuildContext context) {
    if (hasMarkedAttendance) return Colors.green;
    if (!isEnabled) return Colors.grey.shade400;
    return Theme.of(context).colorScheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56.0,
      child: ElevatedButton(
        onPressed: (isEnabled && !hasMarkedAttendance && !isLoading)
            ? onPressed
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _buildBackgroundColor(context),
          disabledBackgroundColor: hasMarkedAttendance
              ? Colors.green.withOpacity(0.7)
              : Colors.grey.shade300,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22.0,
                height: 22.0,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    hasMarkedAttendance
                        ? Icons.check_circle_outline
                        : Icons.fingerprint,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    _buildButtonLabel(),
                    style: const TextStyle(
                      fontSize: 16.0,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
*/


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