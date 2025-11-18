import 'package:flame/src/events/interfaces/multi_drag_listener.dart';
import 'package:flutter/gestures.dart';
import 'package:meta/meta.dart';

/// Helper class to convert drag API as expected by the
/// [ImmediateMultiDragGestureRecognizer] into the API expected by Flame's
/// [MultiDragListener].
@internal
class FlameDragAdapter implements Drag {
  FlameDragAdapter(this._listener, Offset startPoint) {
    start(startPoint);
  }

  final MultiDragListener _listener;
  late final int _id;

  void start(Offset point) {
    final event = DragStartDetails(
      sourceTimeStamp: Duration.zero,
      globalPosition: point,
      localPosition: _listener.renderBox.globalToLocal(point),
    );
    _id = PointerId.next();
    _listener.handleDragStart(_id, event);
  }

  @override
  void update(DragUpdateDetails event) =>
      _listener.handleDragUpdate(_id, event);

  @override
  void end(DragEndDetails event) => _listener.handleDragEnd(_id, event);

  @override
  void cancel() => _listener.handleDragCancel(_id);
}

class PointerId {
  static int _pointerId = 0;

  static int next() {
    return _pointerId++;
  }

  static void reset() {
    _pointerId = 0;
  }
}
