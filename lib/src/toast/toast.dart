import 'package:flutter/material.dart';

import 'package:fluttertoast/fluttertoast.dart';

import 'toast_theme.dart';

/// Provides the [showToast] method as an extension on [BuildContext].
extension ToastScopeContext on BuildContext {
  ColorScheme get _colorScheme => Theme.of(this).colorScheme;
  ToastThemeData get _toastTheme => ToastTheme.of(this);

  /// Shows a toast message using the `fluttertoast` package.
  ///
  /// The toast's appearance is determined by the [ToastThemeData] obtained
  /// from the current [BuildContext].
  void showToast({
    required String message,
    required ToastType toastType,
    ToastAlignment? alignment,
    Duration toastDuration = const Duration(seconds: 2),
    Duration fadeDuration = const Duration(milliseconds: 350),
    bool isDismissible = false,
  }) {
    final fToast = FToast();
    fToast.init(this);

    final toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: _determineBackgroundColor(toastType),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(
            _determineIcon(toastType),
            color: _determineTextColor(toastType),
          ),
          const SizedBox(width: 12.0),
          Text(
            message,
            style: TextStyle(color: _determineTextColor(toastType)),
          ),
        ],
      ),
    );

    fToast.showToast(
      child: toast,
      gravity:
          alignment?.gravity ??
          _toastTheme.alignment?.gravity ??
          ToastGravity.TOP,
      toastDuration: toastDuration,
      fadeDuration: fadeDuration,
      isDismissible: isDismissible,
    );
  }

  Color _determineBackgroundColor(ToastType type) {
    return switch (type) {
      ToastType.succes =>
        _toastTheme.successBackgroundColor ?? _colorScheme.tertiaryContainer,
      ToastType.error =>
        _toastTheme.errorBackgroundColor ?? _colorScheme.errorContainer,
      ToastType.neutral =>
        _toastTheme.neutralBackgroundColor ?? _colorScheme.primaryContainer,
    };
  }

  Color _determineTextColor(ToastType type) {
    return switch (type) {
      ToastType.succes =>
        _toastTheme.successForegroundColor ?? _colorScheme.onTertiaryContainer,
      ToastType.error =>
        _toastTheme.errorForegroundColor ?? _colorScheme.onErrorContainer,
      ToastType.neutral =>
        _toastTheme.neutralForegroundColor ?? _colorScheme.onPrimaryContainer,
    };
  }

  IconData _determineIcon(ToastType type) {
    return switch (type) {
      ToastType.succes => _toastTheme.successIcon ?? Icons.check,
      ToastType.error => _toastTheme.errorIcon ?? Icons.error,
      ToastType.neutral => _toastTheme.neutralIcon ?? Icons.info,
    };
  }
}
