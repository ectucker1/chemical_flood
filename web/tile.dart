import 'package:cobblestone/cobblestone.dart';

class Tile {

  num height;

  int type;

  Vector4 color;
  Vector2 position;

  Tile(this.type, List<Vector4> colors, num x, num y, this.height, num tileSize) {
    this.position = new Vector2(x.toDouble(), height.toDouble());
    print(position);
    new Tween.to(position, Vector2Accessor.XY, (height - y) / 10)
      ..targetValues = [x.toDouble(), y.toDouble()]
      ..easing = Quad.IN
      ..start(tweenManager);
    this.color = colors[type].clone();
  }

  void setY(num y) {
    new Tween.to(position, Vector2Accessor.Y, (height - y) / 10)
      ..targetValues = [y.toDouble()]
      ..easing = Quad.IN
      ..start(tweenManager);
  }

}