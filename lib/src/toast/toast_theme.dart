import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:fluttertoast/fluttertoast.dart';

/// Specifies the alignment of a toast on the screen.
enum ToastAlignment {
  bottom(ToastGravity.BOTTOM),
  bottomLeft(ToastGravity.BOTTOM_LEFT),
  bottomRight(ToastGravity.BOTTOM_RIGHT),
  center(ToastGravity.CENTER),
  centerLeft(ToastGravity.CENTER_LEFT),
  centerRight(ToastGravity.CENTER_RIGHT),
  top(ToastGravity.TOP),
  topLeft(ToastGravity.TOP_LEFT),
  topRight(ToastGravity.TOP_RIGHT);

  const ToastAlignment(this.gravity);

  /// The underlying gravity value from the `fluttertoast` package.
  final ToastGravity gravity;
}

/// The type of toast to be displayed, which determines its default
/// color and icon.
enum ToastType {
  /// Indicates a successful operation.
  succes,

  /// Indicates an error or failure.
  error,

  /// Provides neutral, informational feedback.
  neutral,
}

/// Defines the visual properties of toasts shown by [OverlayCenter].
///
/// Used by [ToastTheme] to pass down toast styling through the widget tree.
@immutable
class ToastThemeData with Diagnosticable {
  /// Creates a theme for customizing toast widgets.
  const ToastThemeData({
    this.successBackgroundColor,
    this.errorBackgroundColor,
    this.neutralBackgroundColor,
    this.successForegroundColor,
    this.errorForegroundColor,
    this.neutralForegroundColor,
    this.successIcon,
    this.errorIcon,
    this.neutralIcon,
    this.alignment,
  });

  /// The background color for success toasts.
  final Color? successBackgroundColor;

  /// The background color for error toasts.
  final Color? errorBackgroundColor;

  /// The background color for neutral toasts.
  final Color? neutralBackgroundColor;

  /// The foreground color (text and icon) for success toasts.
  final Color? successForegroundColor;

  /// The foreground color (text and icon) for error toasts.
  final Color? errorForegroundColor;

  /// The foreground color (text and icon) for neutral toasts.
  final Color? neutralForegroundColor;

  /// The icon for success toasts.
  final IconData? successIcon;

  /// The icon for error toasts.
  final IconData? errorIcon;

  /// The icon for neutral toasts.
  final IconData? neutralIcon;

  /// The default alignment for all toasts.
  final ToastAlignment? alignment;

  /// Creates a copy of this theme but with the given fields replaced with
  /// new values.
  ToastThemeData copyWith({
    Color? successBackgroundColor,
    Color? errorBackgroundColor,
    Color? neutralBackgroundColor,
    Color? successForegroundColor,
    Color? errorForegroundColor,
    Color? neutralForegroundColor,
    IconData? successIcon,
    IconData? errorIcon,
    IconData? neutralIcon,
    ToastAlignment? alignment,
  }) {
    return ToastThemeData(
      successBackgroundColor:
          successBackgroundColor ?? this.successBackgroundColor,
      errorBackgroundColor: errorBackgroundColor ?? this.errorBackgroundColor,
      neutralBackgroundColor:
          neutralBackgroundColor ?? this.neutralBackgroundColor,
      successForegroundColor:
          successForegroundColor ?? this.successForegroundColor,
      errorForegroundColor: errorForegroundColor ?? this.errorForegroundColor,
      neutralForegroundColor:
          neutralForegroundColor ?? this.neutralForegroundColor,
      successIcon: successIcon ?? this.successIcon,
      errorIcon: errorIcon ?? this.errorIcon,
      neutralIcon: neutralIcon ?? this.neutralIcon,
      alignment: alignment ?? this.alignment,
    );
  }

  /// Linearly interpolates between two toast themes.
  static ToastThemeData lerp(ToastThemeData a, ToastThemeData b, double t) {
    return ToastThemeData(
      successBackgroundColor: Color.lerp(
        a.successBackgroundColor,
        b.successBackgroundColor,
        t,
      ),
      errorBackgroundColor: Color.lerp(
        a.errorBackgroundColor,
        b.errorBackgroundColor,
        t,
      ),
      neutralBackgroundColor: Color.lerp(
        a.neutralBackgroundColor,
        b.neutralBackgroundColor,
        t,
      ),
      successForegroundColor: Color.lerp(
        a.successForegroundColor,
        b.successForegroundColor,
        t,
      ),
      errorForegroundColor: Color.lerp(
        a.errorForegroundColor,
        b.errorForegroundColor,
        t,
      ),
      neutralForegroundColor: Color.lerp(
        a.neutralForegroundColor,
        b.neutralForegroundColor,
        t,
      ),
      successIcon: t < 0.5 ? a.successIcon : b.successIcon,
      errorIcon: t < 0.5 ? a.errorIcon : b.errorIcon,
      neutralIcon: t < 0.5 ? a.neutralIcon : b.neutralIcon,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ToastThemeData &&
        other.successBackgroundColor == successBackgroundColor &&
        other.errorBackgroundColor == errorBackgroundColor &&
        other.neutralBackgroundColor == neutralBackgroundColor &&
        other.successForegroundColor == successForegroundColor &&
        other.errorForegroundColor == errorForegroundColor &&
        other.neutralForegroundColor == neutralForegroundColor &&
        other.successIcon == successIcon &&
        other.errorIcon == errorIcon &&
        other.neutralIcon == neutralIcon &&
        other.alignment == alignment;
  }

  @override
  int get hashCode => Object.hash(
    successBackgroundColor,
    errorBackgroundColor,
    neutralBackgroundColor,
    successForegroundColor,
    errorForegroundColor,
    neutralForegroundColor,
    successIcon,
    errorIcon,
    neutralIcon,
    alignment,
  );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      ColorProperty('successBackgroundColor', successBackgroundColor),
    );
    properties.add(ColorProperty('errorBackgroundColor', errorBackgroundColor));
    properties.add(
      ColorProperty('neutralBackgroundColor', neutralBackgroundColor),
    );
    properties.add(
      ColorProperty('successForegroundColor', successForegroundColor),
    );
    properties.add(ColorProperty('errorForegroundColor', errorForegroundColor));
    properties.add(
      ColorProperty('neutralForegroundColor', neutralForegroundColor),
    );
    properties.add(DiagnosticsProperty<IconData>('successIcon', successIcon));
    properties.add(DiagnosticsProperty<IconData>('errorIcon', errorIcon));
    properties.add(DiagnosticsProperty<IconData>('neutralIcon', neutralIcon));
    properties.add(DiagnosticsProperty<ToastAlignment>('aligment', alignment));
  }
}

/// An inherited widget that makes a [ToastThemeData] available to descendants.
///
/// Use this widget to apply a consistent toast style across your app.
class ToastTheme extends InheritedWidget {
  /// Creates a toast theme that controls the style of descendant toasts.
  const ToastTheme({super.key, required this.data, required super.child});

  /// The style configuration for descendant toasts.
  final ToastThemeData data;

  /// The data from the closest [ToastTheme] instance that encloses the given
  /// [BuildContext].
  ///
  /// If no [ToastTheme] is in scope, a default [ToastThemeData] is returned.
  static ToastThemeData of(BuildContext context) {
    final ToastTheme? result = context
        .dependOnInheritedWidgetOfExactType<ToastTheme>();
    return result?.data ?? const ToastThemeData();
  }

  @override
  bool updateShouldNotify(ToastTheme oldWidget) => data != oldWidget.data;
}
