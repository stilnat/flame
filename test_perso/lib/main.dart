import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    GameWidget(game: MyGame()),
  );
}

class MyGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    final center = size / 2;

    // Blue — scalable only (pinch to resize/rotate, no drag)
    await add(InteractiveRectangle(
      position: Vector2(center.x, center.y),
      size: Vector2(180, 120),
      color: Colors.blue,
      isScalable: true,
      isDraggable: false,
    ));

    // Red — draggable only (move around, no pinch)
    await add(InteractiveRectangle(
      position: Vector2(center.x - 125, center.y),
      size: Vector2(180, 120),
      color: Colors.red,
      isScalable: false,
      isDraggable: true,
    ));

    // Green — both scalable and draggable
    await add(InteractiveRectangle(
      position: Vector2(center.x + 125, center.y),
      size: Vector2(180, 120),
      color: Colors.green,
      isScalable: true,
      isDraggable: true,
    ));
  }
}

class InteractiveRectangle extends RectangleComponent
    with ScaleCallbacks, DragCallbacks, HasGameReference<FlameGame> {
  InteractiveRectangle({
    required Vector2 position,
    required Vector2 size,
    Color color = Colors.blue,
    Anchor anchor = Anchor.center,
    this.isScalable = true,
    this.isDraggable = true,
  }) : super(
          position: position,
          size: size,
          anchor: anchor,
          paint: Paint()..color = color,
        );

  /// Whether pinch-to-scale and rotate gestures are enabled.
  final bool isScalable;

  /// Whether drag-to-move gestures are enabled.
  final bool isDraggable;

  bool isDoingScaling = false;
  double initialAngle = 0;
  Vector2 initialScale = Vector2.all(1);
  double lastScale = 1.0;

  @override
  Future<void> onLoad() async {
    // Label reflects what this rectangle can do
    final label = switch ((isDraggable, isScalable)) {
      (true, true) => 'drag + scale',
      (true, false) => 'drag only',
      (false, true) => 'scale only',
      _ => 'locked',
    };

    final text = TextComponent(
      text: label,
      textRenderer: TextPaint(
        style: const TextStyle(fontSize: 22, color: Colors.white),
      ),
      position: size / 2,
      anchor: Anchor.center,
    );
    add(text);
  }

  // ── DragCallbacks ──────────────────────────────────────────────────────────

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    if (!isDraggable) return;
    debugPrint('Drag started at ${event.devicePosition}');
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    if (!isDraggable) return;
    final rotated = event.canvasDelta.clone()
      ..rotate(game.camera.viewfinder.angle);
    position.add(rotated);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    if (!isDraggable) return;
    debugPrint('Drag ended with velocity ${event.velocity}');
  }

  // ── ScaleCallbacks ─────────────────────────────────────────────────────────

  @override
  void onScaleStart(ScaleStartEvent event) {
    super.onScaleStart(event);
    if (!isScalable) return;
    isDoingScaling = true;
    initialAngle = angle;
    initialScale = scale;
    lastScale = 1.0;
    debugPrint('Scale started at ${event.devicePosition}');
  }

  @override
  void onScaleUpdate(ScaleUpdateEvent event) {
    super.onScaleUpdate(event);
    if (!isScalable) return;

    // Apply rotation from pinch gesture
    angle = initialAngle + event.rotation;

    // Delta scale since last frame
    if (lastScale == 0) return;
    final scaleDelta = event.scale / lastScale;
    lastScale = event.scale;

    // Apply delta gently
    scale *= sqrt(scaleDelta);

    // Clamp scale
    scale.clamp(Vector2.all(0.8), Vector2.all(3));
  }

  @override
  void onScaleEnd(ScaleEndEvent event) {
    super.onScaleEnd(event);
    if (!isScalable) return;
    isDoingScaling = false;
    debugPrint('Scale ended with velocity ${event.velocity}');
  }
}
