import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' as w;
import 'package:flutter/material.dart' as m;
import 'package:flutter/cupertino.dart' as c;

import 'package:overlay_center/src/event.dart';
import 'package:overlay_center/src/handler.dart';
import 'package:overlay_center/src/toast/toast.dart';
import 'package:overlay_center/src/toast/toast_theme.dart';
import 'package:overlay_center/src/widget.dart';
import 'package:overlay_center/src/context_extensions.dart';
import 'package:overlay_center/src/testing.dart';

/// A centralized manager for showing overlays like dialogs, bottom sheets, and snackbars.
///
/// `OverlayCenter` provides a simple, consistent API for triggering overlays from
/// anywhere in your app, without needing direct access to `BuildContext`. It relies on
/// an [OverlayHandler] being present in the widget tree.
///
/// Example:
/// ```dart
/// OverlayCenter.instance.showDialog(AlertDialog(title: Text('Hi')));
/// ```
class OverlayCenter {
  OverlayCenter._();

  /// The singleton instance of [OverlayCenter].
  static final instance = OverlayCenter._();

  /// When `true`, an assertion will be thrown if multiple [OverlayHandler]
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
      OverlayRequestEvent<T>(
        eventType: RequestEventType.showDialog,
        callback: (context) => m.showDialog<T>(
          context: context,
          builder: (context) => dialog,
          barrierDismissible: barrierDismissible,
          barrierLabel: barrierLabel,
          fullscreenDialog: fullscreenDialog,
          requestFocus: requestFocus,
        ),
        debugProperties: {
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
      OverlaySendEvent(
        eventType: SendEventType.showBottomSheet,
        callback: (context) =>
            context.showBottomSheet(sheet, duration: duration),
        debugProperties: {
          'sheet': sheet,
          'duration': duration,
          ...debugProperties,
        },
      ),
    );
  }

  /// Shows a [m.SnackBar] at the bottom of the screen.
  void showSnackbar(
    m.SnackBar snackBar, {
    w.AnimationStyle? snackBarAnimationStyle,
    Map<String, dynamic> debugProperties = const {},
  }) {
    return send(
      OverlaySendEvent(
        eventType: SendEventType.showSnackbar,
        callback: (context) => context.showSnackBar(
          snackBar,
          snackBarAnimationStyle: snackBarAnimationStyle,
        ),
        debugProperties: {
          'snackBar': snackBar,
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
      OverlaySendEvent(
        eventType: SendEventType.showMaterialBanner,
        callback: (context) =>
            context.showMaterialBanner(banner, duration: duration),
        debugProperties: {
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
      OverlayRequestEvent(
        eventType: RequestEventType.showModalBottomSheet,
        callback: (context) => m.showModalBottomSheet(
          context: context,
          builder: (context) => sheet,
        ),
        debugProperties: {'sheet': sheet, ...debugProperties},
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
      OverlayRequestEvent(
        eventType: RequestEventType.showCupertinoDialog,
        callback: (context) => c.showCupertinoDialog(
          context: context,
          builder: (context) => dialog,
          barrierDismissible: barrierDismissible,
          barrierLabel: barrierLabel,
          requestFocus: requestFocus,
        ),
        debugProperties: {
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
      OverlayRequestEvent(
        eventType: RequestEventType.showCupertinoModalPopup,
        callback: (context) => c.showCupertinoModalPopup(
          context: context,
          builder: (context) => modal,
          barrierDismissible: barrierDismissible,
          requestFocus: requestFocus,
        ),
        debugProperties: {
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
      OverlayRequestEvent(
        eventType: RequestEventType.showCupertinoSheet,
        callback: (context) => c.showCupertinoSheet(
          context: context,
          builder: (context) => sheet,
          enableDrag: enableDrag,
        ),
        debugProperties: {
          'sheet': sheet,
          'enableDrag': enableDrag,
          ...debugProperties,
        },
      ),
    );
  }

  /// Shows a toast message.
  ///
  /// Toasts are a popular way to provide feedback to users.
  /// This is a custom overlay provided by the package.
  void showToast({
    required String message,
    required ToastType toastType,
    ToastAlignment? alignment,
    Duration toastDuration = const Duration(seconds: 2),
    Duration fadeDuration = const Duration(milliseconds: 350),
    bool isDismissible = false,
    Map<String, dynamic> debugProperties = const {},
  }) {
    send(
      OverlaySendEvent(
        eventType: SendEventType.showToast,
        callback: (context) {
          context.showToast(
            message: message,
            toastType: toastType,
            alignment: alignment,
            toastDuration: toastDuration,
            fadeDuration: fadeDuration,
            isDismissible: isDismissible,
          );
        },
        debugProperties: {
          'message': message,
          'toastType': toastType,
          'alignment': alignment,
          'toastDuration': toastDuration,
          'fadeDuration': fadeDuration,
          'isDismissible': isDismissible,
          ...debugProperties,
        },
      ),
    );
  }

  /// Executes an asynchronous overlay action that can be awaited.
  ///
  /// Dispatches an [OverlayRequestEvent] to the active [OverlayHandler].
  /// This is the foundation for methods like [showDialog].
  Future<T?> request<T>(OverlayRequestEvent<T> event) {
    if (!_assertHasHandler()) return Future.value(null);

    _registered.first.request(event);

    return event.future;
  }

  /// Executes a synchronous overlay action that cannot be awaited.
  ///
  /// Dispatches an [OverlaySendEvent] to the active [OverlayHandler].
  /// This is the foundation for methods like [showSnackbar].
  void send(OverlaySendEvent event) {
    if (!_assertHasHandler()) {
      throw StateError('No handler registered in current page.');
    }

    _registered.first.send(event);
  }

  bool _assertHasHandler() {
    if (_registered.isEmpty) {
      assert(false, '''
      Attempted to handle an overlay method without a Handler being registered.
      Make sure that an OverlayHandler is in the widget tree on the current page.
    ''');

      return false;
    }
    return true;
  }

  /// Registers an [OverlayHandlerElement] with the center.
  ///
  /// This method is intended to be called by [OverlayHandlerElement] when it
  /// is mounted and should not be called directly.
  void registerHandlerElement(OverlayHandlerElement element) {
    assert(!_registered.contains(element), '''
        An overlay handler attempted to register itself to the center a second time. 
        This should not happen and it probably indicates an error in the package. 
        Please make an issue on overlay_center's github page.
      ''');

    if (debugThrowOnMultipleHandlers && _registered.length > 1) {
      assert(_registered.length > 1, '''
          Multiple overlay handlers were registered, this means that you have multiple handlers set up in the current app page.
          If this was intended, you can disable this assertion by setting OverlayCenter.instance.debugThrowOnMultipleHandlers to false.
        ''');
    }

    _registered.add(element);
  }

  /// Deregisters an [OverlayHandlerElement] from the center.
  ///
  /// This method is intended to be called by [OverlayHandlerElement] when it
  /// is unmounted and should not be called directly.
  void deregisterHandlerElement(OverlayHandlerElement element) {
    assert(_registered.contains(element), '''
        An overlay handler attempted to deregister itself from the center while not being registered. 
        This should not happen and it probably indicates an error in the package. 
        Please make an issue on overlay_center's github page.
    ''');
    element.dispose();
    _registered.remove(element);
  }

  /// Registers a [InspectableOverlayHandler] for testing purposes.
  ///
  /// In a test environment, this allows replacing the default UI-rendering
  /// handler with a mock handler that records events for inspection.
  @visibleForTesting
  void registerTestHandler(InspectableOverlayHandler handler) {
    if (_registered.isNotEmpty) {
      throw StateError(
        'Only one test handler can be registered for each test.',
      );
    }
    _registered.add(handler);
  }

  /// Deregisters a [InspectableOverlayHandler].
  ///
  /// Should be called at the end of a test to ensure a clean state.
  /// Returns `true` if the handler was successfully removed.
  @visibleForTesting
  bool deregisterTestHandler(InspectableOverlayHandler handler) {
    handler.dispose();
    return _registered.remove(handler);
  }

  /// Clears all handlers in the [OverlayCenter], essentially resetting it.
  ///
  /// Useful in test environments to ensure no handlers leak between tests.
  @visibleForTesting
  void reset() {
    for (var h in _registered) {
      h.dispose();
    }

    _registered.clear();
  }
}
