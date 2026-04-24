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

    // Blue rectangle — left
    await add(InteractiveRectangle(
      position: Vector2(center.x - 250, center.y),
      size: Vector2(180, 120),
      color: Colors.blue,
    ));

    // Red rectangle — center
    await add(InteractiveRectangle(
      position: Vector2(center.x, center.y),
      size: Vector2(180, 120),
      color: Colors.red,
    ));

    // Green rectangle — right
    await add(InteractiveRectangle(
      position: Vector2(center.x + 250, center.y),
      size: Vector2(180, 120),
      color: Colors.green,
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
  }) : super(
          position: position,
          size: size,
          anchor: anchor,
          paint: Paint()..color = color,
        );

  bool isDoingScaling = false;
  double initialAngle = 0;
  Vector2 initialScale = Vector2.all(1);
  double lastScale = 1.0;

  @override
  Future<void> onLoad() async {
    final text = TextComponent(
      text: 'drag + scale',
      textRenderer: TextPaint(
        style: const TextStyle(fontSize: 25, color: Colors.white),
      ),
      position: size / 2,
      anchor: Anchor.center,
    );
    add(text);
  }

  /// DragCallbacks overrides
  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    debugPrint('Drag started at ${event.devicePosition}');
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    final rotated = event.canvasDelta.clone()
      ..rotate(game.camera.viewfinder.angle);
    position.add(rotated);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    debugPrint('Drag ended with velocity ${event.velocity}');
  }

  /// ScaleCallbacks overrides
  @override
  void onScaleStart(ScaleStartEvent event) {
    super.onScaleStart(event);
    isDoingScaling = true;
    initialAngle = angle;
    initialScale = scale;
    lastScale = 1.0;
    debugPrint('Scale started at ${event.devicePosition}');
  }

  @override
  void onScaleUpdate(ScaleUpdateEvent event) {
    super.onScaleUpdate(event);
    // Rotate rectangle by pinch rotation
    angle = initialAngle + event.rotation;

    // Delta scale since last frame
    if (lastScale == 0) {
      return;
    }
    final scaleDelta = event.scale / lastScale;
    lastScale = event.scale; // update for next frame

    // Apply delta gently
    scale *= sqrt(scaleDelta);

    // Clamp scale
    scale.clamp(Vector2.all(0.8), Vector2.all(3));
  }

  @override
  void onScaleEnd(ScaleEndEvent event) {
    super.onScaleEnd(event);
    isDoingScaling = false;
    debugPrint('Scale ended with velocity ${event.velocity}');
  }
}