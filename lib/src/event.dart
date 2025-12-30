import 'dart:async';

import 'package:flutter/widgets.dart';

/// A generic callback that receives a [BuildContext] and returns a value of type `Future<T?>`.
typedef OverlayRequest<T> = Future<T?> Function(BuildContext context);

/// A generic callback that receives a [BuildContext] and expects no return value.
typedef OverlaySend = void Function(BuildContext context);

/// The type of the request event
///
/// If you are manually setting this property it should probably be [custom]
enum RequestEventType {
  showDialog,
  showModalBottomSheet,
  showCupertinoDialog,
  showCupertinoModalPopup,
  showCupertinoSheet,
  custom,
}

/// The type of the send event
///
/// If you are manually setting this property it should probably be [custom]
enum SendEventType {
  showBottomSheet,
  showSnackbar,
  showMaterialBanner,
  showToast,
  custom,
}

///An [OverlayRequestEvent] is an event that is send to any handlers
/// when an overlay needs to be shown that can pop with a value.
///
///When testing, [eventType] gives information about the type of overlay shown and the [debugProperties]
///gives properties that were given to this request event at runtime.
@immutable
final class OverlayRequestEvent<T> {
  OverlayRequestEvent({
    required this.eventType,
    required this.callback,
    required this.debugProperties,
  }) : _completer = Completer<T?>();

  final RequestEventType eventType;
  final OverlayRequest<T> callback;
  final Map<String, dynamic> debugProperties;
  final Completer<T?> _completer;

  Future<T?> get future => _completer.future;

  void complete(FutureOr<T?> value) {
    _completer.complete(value);
  }
}

///An [OverlaySendEvent] is an event that is send to any handlers when an overlay needs to be shown that does not return a value and can not be awaited.
@immutable
final class OverlaySendEvent {
  const OverlaySendEvent({
    required this.eventType,
    required this.callback,
    required this.debugProperties,
  });

  final SendEventType eventType;
  final OverlaySend callback;
  final Map<String, dynamic> debugProperties;
}
