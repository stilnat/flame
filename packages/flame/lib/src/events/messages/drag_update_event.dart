import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/src/events/messages/displacement_event.dart';
import 'package:flutter/gestures.dart';

class DragUpdateEvent extends DisplacementEvent<DragUpdateDetails> {
  DragUpdateEvent(this.pointerId, super.game, DragUpdateDetails details)
    : timestamp = details.sourceTimeStamp ?? Duration.zero,
      super(
        raw: details,
        deviceStartPosition: details.globalPosition.toVector2(),
        deviceEndPosition:
            details.globalPosition.toVector2() + details.delta.toVector2(),
      );

  final int pointerId;
  final Duration timestamp;

  /// Constructor that builds a DragUpdateEvent from a ScaleUpdateDetails.
  DragUpdateEvent.fromScale(
    this.pointerId,
    FlameGame game,
    ScaleUpdateDetails details,
  ) : timestamp = details.sourceTimeStamp ?? Duration.zero,
      super(
        game,
        raw: DragUpdateDetails(
          globalPosition: details.focalPoint,
          localPosition: details.localFocalPoint,
          delta: details.focalPointDelta,
          sourceTimeStamp: details.sourceTimeStamp,
        ),
        deviceStartPosition: details.focalPoint.toVector2(),
        deviceEndPosition: (details.focalPoint + details.focalPointDelta)
            .toVector2(),
      );

  @override
  String toString() =>
      'DragUpdateEvent('
      'devicePosition: $deviceStartPosition, '
      'canvasPosition: $canvasStartPosition, '
      'delta: $localDelta, '
      'pointerId: $pointerId, '
      'timestamp: $timestamp'
      ')';
}
