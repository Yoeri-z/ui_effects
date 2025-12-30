import 'dart:async';

import 'package:async/async.dart';

import '../center.dart';
import '../event.dart';
import 'handler.dart';

/// An implementation of [Handler] for testing purposes.
///
/// This handler does not render any UI. Instead, it adds overlay events
/// to queues, allowing tests to asynchronously await and inspect them.
///
/// Due to the asynchronous nature of handling events, it is recommended
/// to create a new handler for each test and reset the [OverlayCenter]
/// between tests to ensure a clean state.
///
/// Example:
/// ```dart
/// test('Show and test a dialog', () async {
///   final handler = InspectableOverlayHandler();
///   OverlayCenter.instance.registerTestHandler(handler);
///
///   final future = OverlayCenter.instance.showDialog(AlertDialog(title: Text('Hi')));
///
///   final event = await handler.requests.next;
///   expect(event.eventType, RequestEventType.showDialog);
///
///   event.complete(true);
///   final result = await future;
///   expect(result, isTrue);
///
///   OverlayCenter.instance.reset();
/// });
/// ```
class InspectableOverlayHandler implements Handler {
  /// Creates a new [InspectableOverlayHandler].
  InspectableOverlayHandler() {
    _requestsController = StreamController<OverlayRequestEvent>.broadcast();
    _sendsController = StreamController<OverlaySendEvent>.broadcast();
    requests = StreamQueue(_requestsController.stream);
    sends = StreamQueue(_sendsController.stream);
  }

  late StreamController<OverlayRequestEvent> _requestsController;
  late StreamController<OverlaySendEvent> _sendsController;

  /// A queue of all [OverlayRequestEvent]s that have been recorded.
  ///
  /// Use `await requests.next` to get the next event.
  late StreamQueue<OverlayRequestEvent> requests;

  /// A queue of all [OverlaySendEvent]s that have been recorded.
  ///
  /// Use `await sends.next` to get the next event.
  late StreamQueue<OverlaySendEvent> sends;

  @override
  void request<T>(OverlayRequestEvent<T> event) {
    _requestsController.add(event);
  }

  @override
  void send(OverlaySendEvent event) {
    _sendsController.add(event);
  }

  /// Closes the event streams.
  ///
  /// This should be called when the handler is no longer needed, typically
  /// at the end of a test suite.
  @override
  void dispose() {
    _requestsController.close();
    _sendsController.close();
  }
}
