import 'dart:async';

import 'package:flutter/widgets.dart';

/// A generic callback that receives a [BuildContext] and returns a value of type `Future<T?>`.
typedef Request<T> = Future<T?> Function(BuildContext context);

/// A generic callback that receives a [BuildContext] and expects no return value.
typedef Send = void Function(BuildContext context);

///An [RequestEffect] is an event that is send to any handlers
/// when an effect needs to be shown that can pop with a value.
///
///When testing, [eventType] gives information about the type of effect shown and the [debugProperties]
///gives properties that were given to this request event at runtime.
@immutable
final class RequestEffect<T> {
  /// Construct a ui effect.
  RequestEffect({required this.callback, required this.debugProperties})
    : _completer = Completer<T?>();

  /// Callback that is called when context is acquired
  final Request<T> callback;

  /// Debug properties about the event, readable when using a [InspectableEffectHandler]
  final Map<String, dynamic> debugProperties;

  final Completer<T?> _completer;

  /// The future this event will eventually return when the user input completes.
  Future<T?> get future => _completer.future;

  void complete(FutureOr<T?> value) {
    _completer.complete(value);
  }
}

///An [SendEffect] is an event that is send to any handlers when an effect needs to be shown that does not return a value and can not be awaited.
@immutable
final class SendEffect {
  /// Construct an [SendEffect]
  const SendEffect({required this.callback, required this.debugProperties});

  /// Callback that is called when context is acquired
  final Send callback;

  /// Debug properties about the event, readable when using a [InspectableEffectHandler]
  final Map<String, dynamic> debugProperties;
}
