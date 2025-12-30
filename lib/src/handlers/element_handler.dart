import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:overlay_center/src/center.dart';
import 'package:overlay_center/src/event.dart';
import 'package:overlay_center/src/handlers/handler.dart';

/// A widget that provides a [BuildContext] for the [OverlayCenter] to show overlays.
///
/// An [OverlayHandler] should be placed in your widget tree, typically
/// above the `MaterialApp` or `CupertinoApp`, so that overlays can be
/// displayed from anywhere in your application.
///
/// Example:
/// ```dart
/// OverlayHandler(
///   child: MaterialApp(
///     ...
///   ),
/// )
/// ```
class OverlayHandler extends Widget {
  /// Creates a widget that enables overlay functionality for its descendants.
  const OverlayHandler({super.key, required this.child});

  /// The widget below this widget in the tree.
  final Widget child;

  @override
  OverlayHandlerElement createElement() => OverlayHandlerElement(this);
}

/// The element for [OverlayHandler].
///
/// This element implements the [Handler] interface and registers itself with
/// [OverlayCenter] when it's mounted, and deregisters when unmounted.
class OverlayHandlerElement extends ComponentElement implements Handler {
  /// Creates an element that uses the given widget as its configuration.
  OverlayHandlerElement(super.widget);

  @override
  Future<void> request<T>(OverlayRequestEvent<T> event) async {
    event.complete(event.callback(this));
  }

  @override
  void send(OverlaySendEvent event) {
    event.callback(this);
  }

  @override
  Widget build() => (widget as OverlayHandler).child;

  @override
  void update(OverlayHandler newWidget) {
    //implementation copied from [StatelessElement]
    super.update(newWidget);
    assert(widget == newWidget);
    rebuild(force: true);
  }

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    OverlayCenter.instance.registerHandlerElement(this);
  }

  @override
  void unmount() {
    OverlayCenter.instance.deregisterHandlerElement(this);
    super.unmount();
  }

  @override
  void dispose() {}
}
