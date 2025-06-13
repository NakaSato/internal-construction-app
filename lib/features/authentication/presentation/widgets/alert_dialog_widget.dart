import 'package:flutter/material.dart';

enum AlertType { error, success, warning, info }

class AlertDialogWidget extends StatelessWidget {
  final String title;
  final String message;
  final AlertType type;
  final VoidCallback? onPressed;
  final String? buttonText;

  const AlertDialogWidget({
    Key? key,
    required this.title,
    required this.message,
    required this.type,
    this.onPressed,
    this.buttonText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(_getIcon(), color: _getColor(), size: 24),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(color: _getColor(), fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: Text(message, style: const TextStyle(fontSize: 16)),
      actions: [
        TextButton(
          onPressed: onPressed ?? () => Navigator.of(context).pop(),
          child: Text(buttonText ?? 'OK', style: TextStyle(color: _getColor())),
        ),
      ],
    );
  }

  IconData _getIcon() {
    switch (type) {
      case AlertType.error:
        return Icons.error_outline;
      case AlertType.success:
        return Icons.check_circle_outline;
      case AlertType.warning:
        return Icons.warning_outlined;
      case AlertType.info:
        return Icons.info_outline;
    }
  }

  Color _getColor() {
    switch (type) {
      case AlertType.error:
        return Colors.red;
      case AlertType.success:
        return Colors.green;
      case AlertType.warning:
        return Colors.orange;
      case AlertType.info:
        return Colors.blue;
    }
  }
}
