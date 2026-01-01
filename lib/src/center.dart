import 'dart:async';
import 'dart:collection';

import 'package:flutter/widgets.dart' as w;
import 'package:flutter/cupertino.dart' as c;
import 'package:flutter/material.dart' as m;

import 'effect.dart';
import 'handlers/handler.dart';
import 'handlers/element_handler.dart';
import 'context_extensions.dart';

/// A centralized manager for showing ui (side) effects like dialogs, bottom sheets, and snackbars.
///
/// `UICenter` provides a simple, consistent API for triggering effects from
/// anywhere in your app, without needing direct access to `BuildContext`. It relies on
/// an [EffectHandler] being present in the widget tree.
///
/// Example:
/// ```dart
/// UICenter.instance.showDialog(AlertDialog(title: Text('Hi')));
/// ```
class UICenter {
  UICenter._();

  /// The singleton instance of [UICenter].
  static final instance = UICenter._();

  /// When `true`, an assertion will be thrown if multiple [EffectHandler]
  /// widgets are registered on the same page.
  ///
  /// This is useful for debugging to ensure that there's only one handler active
  /// at a time. If having multiple handlers is intended, set this to `false`.
  /// Defaults to `true`.
  bool debugThrowOnMultipleHandlers = true;

  final _registered = HashSet<Handler>();

  /// Displays a Material dialog.
  ///
  /// Returns a [Future] that completes to the value passed to `Navigator.pop`
  /// when the dialog is closed.
  Future<T?> showDialog<T>(
    m.Widget dialog, {
    bool barrierDismissible = true,
    String? barrierLabel,
    bool fullscreenDialog = false,
    bool? requestFocus,
    Map<String, dynamic> debugProperties = const {},
  }) {
    return request<T>(
      RequestEffect<T>(
        callback: (context) => m.showDialog<T>(
          context: context,
          builder: (context) => dialog,
          barrierDismissible: barrierDismissible,
          barrierLabel: barrierLabel,
          fullscreenDialog: fullscreenDialog,
          requestFocus: requestFocus,
        ),
        debugProperties: {
          'caller': 'showDialog',
          'dialog': dialog,
          'barrierDismissible': barrierDismissible,
          'barrierLabel': barrierLabel,
          'fullscreenDialog': fullscreenDialog,
          'requestFocus': requestFocus,
          ...debugProperties,
        },
      ),
    );
  }

  /// Displays a Material bottom sheet.
  ///
  /// If a [duration] is provided, the bottom sheet will close automatically
  /// after the given duration.
  void showBottomSheet<T>(
    m.Widget sheet, {
    Duration? duration,
    Map<String, dynamic> debugProperties = const {},
  }) {
    return send(
      SendEffect(
        callback: (context) =>
            context.showBottomSheet(sheet, duration: duration),
        debugProperties: {
          'caller': 'showBottomSheet',
          'sheet': sheet,
          'duration': duration,
          ...debugProperties,
        },
      ),
    );
  }

  /// Shows a [m.SnackBar] at the bottom of the screen.
  void showSnackBar(
    m.SnackBar snackBar, {
    Duration? duration,
    w.AnimationStyle? snackBarAnimationStyle,
    Map<String, dynamic> debugProperties = const {},
  }) {
    return send(
      SendEffect(
        callback: (context) => context.showSnackBar(
          snackBar,
          duration: duration,
          snackBarAnimationStyle: snackBarAnimationStyle,
        ),
        debugProperties: {
          'caller': 'showSnackBar',
          'snackBar': snackBar,
          'duration': duration,
          'snackBarAnimationStyle': snackBarAnimationStyle,
          ...debugProperties,
        },
      ),
    );
  }

  /// Shows a [m.MaterialBanner] at the top of the screen.
  ///
  /// If a [duration] is provided, the banner will close automatically
  /// after the given duration.
  void showMaterialBanner(
    m.MaterialBanner banner, {
    Duration? duration,
    Map<String, dynamic> debugProperties = const {},
  }) {
    return send(
      SendEffect(
        callback: (context) =>
            context.showMaterialBanner(banner, duration: duration),
        debugProperties: {
          'caller': 'showMaterialBanner',
          'banner': banner,
          'duration': duration,
          ...debugProperties,
        },
      ),
    );
  }

  /// Displays a modal Material bottom sheet.
  ///
  /// A modal bottom sheet prevents the user from interacting with the rest
  /// of the app.
  Future<T?> showModalBottomSheet<T>(
    m.Widget sheet, {
    Map<String, dynamic> debugProperties = const {},
  }) {
    return request(
      RequestEffect(
        callback: (context) => m.showModalBottomSheet(
          context: context,
          builder: (context) => sheet,
        ),
        debugProperties: {
          'caller': 'showModalBottomSheet',
          'sheet': sheet,
          ...debugProperties,
        },
      ),
    );
  }

  /// Displays a Cupertino-style dialog.
  ///
  /// Returns a [Future] that completes to the value passed to `Navigator.pop`
  /// when the dialog is closed.
  Future<T?> showCupertinoDialog<T>(
    c.Widget dialog, {
    bool barrierDismissible = true,
    String? barrierLabel,
    bool? requestFocus,
    Map<String, dynamic> debugProperties = const {},
  }) {
    return request(
      RequestEffect(
        callback: (context) => c.showCupertinoDialog(
          context: context,
          builder: (context) => dialog,
          barrierDismissible: barrierDismissible,
          barrierLabel: barrierLabel,
          requestFocus: requestFocus,
        ),
        debugProperties: {
          'caller': 'showCupertinoDialog',
          'dialog': dialog,
          'barrierDismissible': barrierDismissible,
          'barrierLabel': barrierLabel,
          'requestFocus': requestFocus,
          ...debugProperties,
        },
      ),
    );
  }

  /// Shows a Cupertino-style modal popup that slides up from the bottom
  /// of the screen.
  Future<T?> showCupertinoModalPopup<T>(
    c.Widget modal, {
    bool barrierDismissible = true,
    bool? requestFocus,
    Map<String, dynamic> debugProperties = const {},
  }) {
    return request(
      RequestEffect(
        callback: (context) => c.showCupertinoModalPopup(
          context: context,
          builder: (context) => modal,
          barrierDismissible: barrierDismissible,
          requestFocus: requestFocus,
        ),
        debugProperties: {
          'caller': 'showCupertinoModalPopup',
          'modal': modal,
          'barrierDismissible': barrierDismissible,
          'requestFocus': requestFocus,
          ...debugProperties,
        },
      ),
    );
  }

  /// Shows a Cupertino-style bottom sheet.
  Future<T?> showCupertinoSheet<T>(
    c.Widget sheet, {
    bool enableDrag = true,
    Map<String, dynamic> debugProperties = const {},
  }) {
    return request(
      RequestEffect(
        callback: (context) => c.showCupertinoSheet(
          context: context,
          builder: (context) => sheet,
          enableDrag: enableDrag,
        ),
        debugProperties: {
          'caller': 'showCupertinoSheet',
          'sheet': sheet,
          'enableDrag': enableDrag,
          ...debugProperties,
        },
      ),
    );
  }

  /// Executes an asynchronous ui effect that can be awaited.
  ///
  /// Dispatches a [RequestEffect] to the active [EffectHandler].
  /// This is the foundation for methods like [showDialog].
  Future<T?> request<T>(RequestEffect<T> event) {
    if (!_assertHasHandler()) return Future.value(null);

    _registered.first.request(event);

    return event.future;
  }

  /// Executes a ui effect that cannot be awaited.
  ///
  /// Dispatches a [SendEffect] to the active [EffectHandler].
  /// This is the foundation for methods like [showSnackBar].
  void send(SendEffect event) {
    if (!_assertHasHandler()) return;

    _registered.first.send(event);
  }

  bool _assertHasHandler() {
    if (_registered.isEmpty) {
      assert(false, '''
      Attempted to handle a ui effect without a Handler being registered.
      Make sure that an EffectHandler is in the widget tree on the current page.
    ''');

      return false;
    }
    return true;
  }

  /// Registers an [Handler] with the center.
  ///
  /// This method is intended to be called by [Handler] when it
  /// is mounted and should not be called directly.
  void registerHandler(Handler handler) {
    assert(!_registered.contains(handler), '''
        An effect handler attempted to register itself to the center a second time. 
        This should not happen and it probably indicates an error in the package. 
        Please make an issue on ui_effects's github page.
      ''');

    if (debugThrowOnMultipleHandlers && _registered.length > 1) {
      assert(_registered.length > 1, '''
          Multiple effect handlers were registered, this means that you have multiple handlers set up in the current app page.
          If this was intended, you can disable this assertion by setting UICenter.instance.debugThrowOnMultipleHandlers to false.
        ''');
    }

    _registered.add(handler);
  }

  /// Deregisters a [Handler] from the center.
  ///
  /// This method is intended to be called by [EffectHandlerElement] when it
  /// is unmounted and should not be called directly.
  void deregisterHandler(Handler handler) {
    assert(_registered.contains(handler), '''
        A effect handler attempted to deregister itself from the center while not being registered. 
        This should not happen and it probably indicates an error in the package. 
        Please make an issue on ui_effects's github page.
    ''');
    _registered.remove(handler);
  }
}
