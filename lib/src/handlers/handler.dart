import 'package:overlay_center/src/event.dart';

/// Defines the contract for an overlay handler.
///
/// A [Handler] is responsible for processing overlay events dispatched
/// by the [OverlayCenter]. This allows for different implementations, such
/// as one that renders UI and another for testing.
abstract interface class Handler {
  /// Handles an [OverlayRequestEvent] that expects a value in return.
  ///
  /// The handler should execute the overlay and complete the event's
  /// future when the overlay is dismissed.
  void request<T>(OverlayRequestEvent<T> event);

  /// Handles an [OverlaySendEvent] that is fire-and-forget.
  ///
  /// The handler should execute the overlay action without needing
  /// to return a value.
  void send(OverlaySendEvent event);

  void dispose();
}
