import 'dart:async';

import 'package:async/async.dart';

import '../center.dart';
import '../effect.dart';
import 'handler.dart';

/// A matcher for a [RequestEffect].
typedef RequestMatcher<T> = bool Function(RequestEffect<T> request);

/// A matcher for a [SendEffect].
typedef SendMatcher = bool Function(SendEffect effect);

class _MatchJob<T> {
  const _MatchJob({required this.matcher, required this.answer});

  final RequestMatcher<T>? matcher;
  final FutureOr<T?> answer;

  bool match(RequestEffect<T> request) {
    return matcher?.call(request) ?? true;
  }
}

/// An implementation of [Handler] for testing purposes.
///
/// This handler does not render any UI. Instead, it adds effects
/// to queues, allowing tests to asynchronously await and inspect them.
///
/// Due to the asynchronous nature of ui side effects, it is recommended
/// to create a new handler for each test and dispose it
/// between tests to ensure a clean state.
///
/// Example:
/// ```dart
/// test('Show and test a dialog', () async {
///   final handler = InspectableEffectHandler();
///
///   final future = UICenter.instance.showDialog(AlertDialog(title: Text('Hi')));
///
///   final event = await handler.requests.next;
///   expect(event.eventType, RequestEventType.showDialog);
///
///   event.complete(true);
///   expect(await future, isTrue);
///
///   handler.dispose
/// });
/// ```
class InspectableEffectHandler implements Handler {
  /// Creates a new [InspectableEffectHandler].
  InspectableEffectHandler()
    : _requestsController = StreamController<RequestEffect>.broadcast(),
      _sendsController = StreamController<SendEffect>.broadcast() {
    requests = StreamQueue(_requestsController.stream);
    sends = StreamQueue(_sendsController.stream);
    UICenter.instance.registerHandler(this);
  }

  final StreamController<RequestEffect> _requestsController;
  final StreamController<SendEffect> _sendsController;

  /// A queue of all [RequestEffect]s that have been recorded.
  ///
  /// Use `await requests.next` to get the next event.
  late final StreamQueue<RequestEffect> requests;

  /// A queue of all [SendEffect]s that have been recorded.
  ///
  /// Use `await sends.next` to get the next event.
  late final StreamQueue<SendEffect> sends;

  /// A stream of all [RequestEffect]s that have been recorded.
  Stream<RequestEffect> get requestStream => _requestsController.stream;

  /// A stream of all [SendEffect]s that have been recorded.
  Stream<SendEffect> get sendStream => _sendsController.stream;

  final _jobs = <_MatchJob>[];

  @override
  void request<T>(RequestEffect<T> effect) async {
    bool matched = false;

    for (final job in _jobs) {
      if (job is _MatchJob<T> && job.match(effect)) {
        effect.complete(await job.answer);
        matched = true;
        break;
      }
    }

    if (!matched) {
      effect.completeError(
        StateError('No request handler matched: $effect'),
        StackTrace.current,
      );
    }

    _requestsController.add(effect);
  }

  @override
  void send(SendEffect effect) {
    _sendsController.add(effect);
  }

  /// Define an answer to be returned when a request for type [T] happens.
  ///
  /// [matcher] can optionally be supplied to make the match more strict based on [RequestEffect.debugProperties].
  /// [answer] is the answer to be returned when such a request happens.
  void whenRequest<T>({
    RequestMatcher<T>? matcher,
    required FutureOr<T?> answer,
  }) async {
    _jobs.add(_MatchJob<T>(matcher: matcher, answer: answer));
  }

  /// Closes the event streams.
  ///
  /// This should be called when the handler is no longer needed, typically
  /// at the end of a test suite.
  void dispose() {
    _requestsController.close();
    _sendsController.close();
    _jobs.clear();
    UICenter.instance.deregisterHandler(this);
  }
}
