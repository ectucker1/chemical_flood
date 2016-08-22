import 'package:cobblestone/cobblestone.dart';
import 'array_2d.dart';
import 'tile.dart';

const int BOARD_HEIGHT = 9;
const int BOARD_WIDTH = 5;

const int TYPES = 7;

List<Vector4> types = [Colors.red, Colors.orange, Colors.yellow, Colors.limeGreen, Colors.cyan, Colors.blue, Colors.purple];

main() {
  new ChemicalGame();
}

class ChemicalGame extends BaseGame {

  Camera2D camera;

  SpriteBatch batch;
  GameTexture brick, borderLeft, borderRight;

  Random rand;

  int get tileSize => (width / BOARD_HEIGHT / 3).round();

  List2D<Tile> tiles;
  List<Tile> key;
  List<Tile> faders;

  bool add = true;

  int score = 0;

  bool over = false;

  Sound bgm;

  var scoreElement;
  var overMessage;

  @override
  create() {
    camera = new Camera2D.originBottomLeft(width, height);
    batch = new SpriteBatch.defaultShader();

    setGLViewport(canvasWidth, canvasHeight);

    rand = new Random();

    brick = assetManager.get("brick.png");
    borderLeft = assetManager.get("borderLeft.png");
    borderRight = assetManager.get("borderRight.png");

    canvas.onClick.listen(clickLeft);
    canvas.onContextMenu.listen(clickRight);

    tiles = new List2D<Tile>(BOARD_WIDTH, BOARD_HEIGHT);
    key = [];
    faders = [];
    for(int i = 0; i < TYPES; i++) {
      key.add(new Tile(i, types, 0, i, BOARD_HEIGHT * 2, tileSize));
    }

    scoreElement = querySelector('#scoreboard');
    overMessage = querySelector('#gameover');
    scoreElement.text = "Score: $score";

    bgm = assetManager.get("background.wav");
    bgm.loop();
  }

  @override
  config() {
    scaleMode = ScaleMode.resize;
  }

  void clickLeft(MouseEvent event) {
    click(event, false);
  }

  void clickRight(MouseEvent event) {
    event.preventDefault();
    click(event, true);
  }

  void click(MouseEvent me, bool right) {
    if(!over) {
      Vector2 tile = unproject(me.client.x, me.client.y);
      int x = tile.x.toInt();
      int y = tile.y.toInt();
      int index = tiles.index(x, y);
      if (index <= tiles.length) {
        if (tiles.get(x, y) != null) {
          if (!right) {
            tiles.get(x, y).type = tiles.get(x, y).type + 1;
          } else if (right) {
            tiles.get(x, y).type = tiles.get(x, y).type - 1;
          }
          if (tiles.get(x, y).type >= TYPES) {
            tiles.get(x, y).type = 0;
          }
          if (tiles.get(x, y).type < 0) {
            tiles.get(x, y).type = TYPES - 1;
          }
          Vector4 newColor = types[tiles.get(x, y).type];
          new Tween.to(tiles.get(x, y).color, Vector4Accessor.RGBA, 0.4)
            ..easing = Quart.INOUT
            ..targetValues = [newColor.r, newColor.g, newColor.b, 1]
            ..start(tweenManager);
          add = true;
        }
      }
    }
  }

  Vector2 unproject(num x, num y) {
    Matrix4 negate = camera.combined.clone();
    negate.negate();
    //Vector3 point = negate.transform3(new Vector3(x.toDouble(), y.toDouble(), 0.0));
    Vector3 point = new Vector3(x.toDouble(), canvasHeight - y.toDouble(), 0.0);
    point.scale(width / canvasWidth);
    point.scale(1 / tileSize);
    point.floor();
    return point.xy;
  }

  @override
  preload() {
    assetManager.load("brick.png", loadTexture("art/brick.png", nearest));
    assetManager.load("borderLeft.png", loadTexture("art/borderLeft.png", nearest));
    assetManager.load("borderRight.png", loadTexture("art/borderRight.png", nearest));
    assetManager.load("background.wav", loadGameSound("music/background.wav"));
  }

  @override
  render(num delta) {
    clearScreen(0.0, 0.0, 0.0, 1.0);

    camera.update();

    batch.projection = camera.combined;
    batch.begin();

    for(Tile tile in tiles.list) {
      if(tile != null) {
        batch.color = tile.color;
        batch.draw(brick, tile.position.x * tileSize,
            tile.position.y * tileSize, tileSize, tileSize);
      }
    }
    for(Tile tile in key) {
      batch.color = tile.color;
      batch.draw(brick, width - tileSize, tile.position.y * tileSize, tileSize, tileSize);
    }
    for(Tile tile in faders) {
      batch.color = tile.color;
      batch.draw(brick, tile.position.x * tileSize,
          tile.position.y * tileSize, tileSize, tileSize);
    }
    for(int i = 0; i < TYPES; i++) {
      batch.color = Colors.white;
      batch.draw(borderLeft, width - tileSize * 1.25, i * tileSize, tileSize / 4, tileSize);
    }
    for(int i = 0; i < BOARD_HEIGHT; i++) {
      batch.color = Colors.white;
      batch.draw(borderRight, BOARD_WIDTH * tileSize, i * tileSize, tileSize / 4, tileSize);
    }

    batch.end();
  }

  resize(num width, num height) {
    setGLViewport(canvasWidth, canvasHeight);
    camera = new Camera2D.originBottomLeft(width, height);
  }

  @override
  update(num delta) {
    if(!over) {
      clearRow();
      if(add) {
        if(tiles.indexOf(null) != -1) {
          tiles.set(tiles.xCoord(tiles.indexOf(null)), tiles.yCoord(tiles.indexOf(null)),
              new Tile(rand.nextInt(TYPES), types,
                  tiles.xCoord(tiles.indexOf(null)), tiles.yCoord(tiles.indexOf(null)),
                  BOARD_HEIGHT + 4, tileSize));
        } else {
          overMessage.style.opacity = "1";
          over = true;
        }
        add = false;
      }
    }
  }

  bool clearRow()
  {
    for(int y = 0; y < BOARD_HEIGHT; y++)
    {
      int goodTiles = 0;
      int lastType = -1;
      for(int x = 0; x < BOARD_WIDTH; x++)
      {
        if(tiles.get(x, y) != null)
        {
          if(x == 0)
          {
            lastType = tiles.get(x, y).type;
          }
          if(tiles.get(x, y).type == lastType)
          {
            goodTiles++;
          }
        }
      }

      if(goodTiles == BOARD_WIDTH)
      {
        for(int x = 0; x < BOARD_WIDTH; x++)
        {
          faders.add(tiles.get(x, y));
          new Tween.to(tiles.get(x, y).color, Vector4Accessor.RGBA, 0.5)
              ..targetValues = [0, 0, 0, 1]
              ..easing = Quart.OUT
              ..callback = clearFaders
              ..start(tweenManager);
          tiles.set(x, y, null);
        }
        score += BOARD_WIDTH;
        scoreElement.text = "Score: $score";
      }

    }

    bool fall = false;
    for(int y = 1; y < BOARD_HEIGHT; y++)
    {
      for(int x = 0; x < BOARD_WIDTH; x++)
      {
        if(tiles.get(x, y) != null && tiles.get(x, y - 1) == null)
        {
          tiles.set(x, y - 1, tiles.get(x, y));
          tiles.set(x, y, null);
          tiles.get(x, y - 1).setY(y - 1);
          fall = true;
        }
      }
    }

    return fall;
  }

  void clearFaders(int type, BaseTween source) {
    faders.clear();
  }

}