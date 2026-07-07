import 'package:flutter/material.dart';
import 'models/picker_config.dart';

/// Thanh action Hủy / Xác nhận dùng chung cho tất cả picker dialog.
class PickerActionBar extends StatelessWidget {
  final PickerThemeData theme;
  final PickerLocale locale;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const PickerActionBar({
    super.key,
    required this.theme,
    required this.locale,
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            // withValues thay thế withOpacity — Flutter 3.27+
            color: theme.onSurface.withValues(alpha: 0.1),
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(8, 6, 12, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: onCancel,
            style: TextButton.styleFrom(
              foregroundColor: theme.onSurface.withValues(alpha: 0.6),
            ),
            child: Text(locale.cancelText),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: onConfirm,
            style: FilledButton.styleFrom(
              backgroundColor: theme.primary,
              foregroundColor: theme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(locale.confirmText),
          ),
        ],
      ),
    );
  }
}
