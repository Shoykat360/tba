import 'package:flutter/material.dart';

class SetLocationButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onPressed;
  final bool hasLocation;

  const SetLocationButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
    required this.hasLocation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: theme.colorScheme.primary,
          ),
        )
            : Icon(
          hasLocation ? Icons.edit_location_alt_rounded : Icons.add_location_rounded,
        ),
        label: Text(
          isLoading
              ? 'Saving location...'
              : hasLocation
              ? 'Update Office Location'
              : 'Set Office Location',
        ),
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
