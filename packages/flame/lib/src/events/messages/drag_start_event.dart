import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/src/events/messages/drag_end_event.dart';
import 'package:flame/src/events/messages/drag_update_event.dart';
import 'package:flame/src/events/messages/position_event.dart';
import 'package:flutter/gestures.dart';

/// The event propagated through the Flame engine when the user starts a drag
/// gesture on the game canvas.
///
/// This is a [PositionEvent], where the position is the point of touch.
class DragStartEvent extends PositionEvent<DragStartDetails> {
  DragStartEvent(this.pointerId, super.game, DragStartDetails details)
    : deviceKind = details.kind ?? PointerDeviceKind.unknown,
      super(
        raw: details,
        devicePosition: details.globalPosition.toVector2(),
      );

  /// Constructor that builds a DragStartEvent from a ScaleStartDetails.
  DragStartEvent.fromScale(
    this.pointerId,
    FlameGame game,
    ScaleStartDetails details,
  ) : deviceKind = details.kind ?? PointerDeviceKind.unknown,
      super(
        game,
        raw: DragStartDetails(
          globalPosition: details.focalPoint,
          localPosition: details.localFocalPoint,
          sourceTimeStamp: details.sourceTimeStamp,
          kind: details.kind,
        ),
        devicePosition: details.focalPoint.toVector2(),
      );

  /// The unique identifier of the drag event.
  ///
  /// Subsequent [DragUpdateEvent] or [DragEndEvent] will carry the same pointer
  /// id. This allows distinguishing multiple drags that may occur at the same
  /// time on the same component.
  final int pointerId;

  final PointerDeviceKind deviceKind;

  @override
  String toString() =>
      'DragStartEvent(canvasPosition: $canvasPosition, '
      'devicePosition: $devicePosition, '
      'pointedId: $pointerId, deviceKind: $deviceKind)';
}
