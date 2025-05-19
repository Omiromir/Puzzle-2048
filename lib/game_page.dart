// ignore: unused_import
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'game/tile.dart';
import 'game/grid_properties.dart';

enum SwipeDirection { up, down, left, right }

class GameState {
  final List<List<Tile>> _previousGrid;
  final SwipeDirection swipe;

  GameState(List<List<Tile>> previousGrid, this.swipe) : _previousGrid = previousGrid;

  List<List<Tile>> get previousGrid =>
      _previousGrid.map((row) => row.map((tile) => tile.copy()).toList()).toList();
}

class NewGamePage extends StatelessWidget {
  const NewGamePage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(t.newGame)),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const GamePage()),
            );
          },
          child: Text(t.startGame),
        ),
      ),
    );
  }
}

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with SingleTickerProviderStateMixin {
  late AnimationController controller;

  List<List<Tile>> grid = List.generate(4, (y) => List.generate(4, (x) => Tile(x, y, 0)));
  List<GameState> gameStates = [];
  List<Tile> toAdd = [];

  int score = 0;

  Iterable<Tile> get gridTiles => grid.expand((e) => e);
  Iterable<Tile> get allTiles => [gridTiles, toAdd].expand((e) => e);
  List<List<Tile>> get gridCols => List.generate(4, (x) => List.generate(4, (y) => grid[y][x]));

  @override
  void initState() {
    super.initState();
    controller = AnimationController(duration: const Duration(milliseconds: 200), vsync: this);
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          for (var e in toAdd) {
            grid[e.y][e.x].value = e.value;
          }
          for (var t in gridTiles) {
            t.resetAnimations();
          }
          toAdd.clear();
        });
      }
    });
    _setupNewGame();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _setupNewGame() {
    setState(() {
      gameStates.clear();
      score = 0;
      for (var t in gridTiles) {
        t.value = 0;
        t.resetAnimations();
      }
      toAdd.clear();
      _addNewTiles([2, 2]);
      controller.forward(from: 0);
    });
  }

  void _addNewTiles(List<int> values) {
    List<Tile> empty = gridTiles.where((t) => t.value == 0).toList();
    if (empty.length < values.length) return;
    empty.shuffle();
    for (int i = 0; i < values.length; i++) {
      toAdd.add(Tile(empty[i].x, empty[i].y, values[i])..appear(controller));
    }
  }

  void _merge(SwipeDirection direction) {
    bool Function() mergeFn;
    switch (direction) {
      case SwipeDirection.up:
        mergeFn = _mergeUp;
        break;
      case SwipeDirection.down:
        mergeFn = _mergeDown;
        break;
      case SwipeDirection.left:
        mergeFn = _mergeLeft;
        break;
      case SwipeDirection.right:
        mergeFn = _mergeRight;
        break;
    }

    List<List<Tile>> gridBeforeSwipe =
        grid.map((row) => row.map((tile) => tile.copy()).toList()).toList();

    setState(() {
      if (mergeFn()) {
        gameStates.add(GameState(gridBeforeSwipe, direction));
        _addNewTiles([2]);
        controller.forward(from: 0);
        if (!_hasValidMoves()) {
          _showGameOverDialog();
        }
      }
    });
  }

  bool _hasValidMoves() {
    return gridTiles.any((t) => t.value == 0) ||
        _canMerge(grid) || _canMerge(gridCols);
  }

  bool _canMerge(List<List<Tile>> rows) {
    for (var row in rows) {
      for (int i = 0; i < row.length - 1; i++) {
        if (row[i].value == row[i + 1].value) return true;
      }
    }
    return false;
  }

  bool _mergeLeft() {
    bool changed = false;
    for (int y = 0; y < 4; y++) {
      List<Tile> row = grid[y];
      bool rowChanged = _mergeTiles(row);
      if (rowChanged) changed = true;
    }
    return changed;
  }

  bool _mergeRight() {
    bool changed = false;
    for (int y = 0; y < 4; y++) {
      List<Tile> row = grid[y].reversed.toList();
      bool rowChanged = _mergeTiles(row);
      if (rowChanged) changed = true;
      grid[y] = row.reversed.toList();
    }
    return changed;
  }

  bool _mergeUp() {
    bool changed = false;
    for (int x = 0; x < 4; x++) {
      List<Tile> col = List.generate(4, (y) => grid[y][x]);
      bool colChanged = _mergeTiles(col);
      if (colChanged) changed = true;
      for (int y = 0; y < 4; y++) {
        grid[y][x] = col[y];
      }
    }
    return changed;
  }

  bool _mergeDown() {
    bool changed = false;
    for (int x = 0; x < 4; x++) {
      List<Tile> col = List.generate(4, (y) => grid[y][x]).reversed.toList();
      bool colChanged = _mergeTiles(col);
      if (colChanged) changed = true;
      List<Tile> fixed = col.reversed.toList();
      for (int y = 0; y < 4; y++) {
        grid[y][x] = fixed[y];
      }
    }
    return changed;
  }

  bool _mergeTiles(List<Tile> tiles) {
    bool didChange = false;
    for (int i = 0; i < tiles.length; i++) {
      for (int j = i; j < tiles.length; j++) {
        if (tiles[j].value != 0) {
          Tile? mergeTile = tiles.skip(j + 1).firstWhere(
            (t) => t.value != 0,
            orElse: () => Tile(-1, -1, 0),
          );

          if (mergeTile.x == -1 || mergeTile.value != tiles[j].value) {
            mergeTile = null;
          }

          if (i != j || mergeTile != null) {
            didChange = true;
            int resultValue = tiles[j].value;
            tiles[j].moveTo(controller, tiles[i].x, tiles[i].y);
            if (mergeTile != null) {
              resultValue += mergeTile.value;
              score += resultValue;
              mergeTile.moveTo(controller, tiles[i].x, tiles[i].y);
              mergeTile.bounce(controller);
              mergeTile.changeNumber(controller, resultValue);
              mergeTile.value = 0;
              tiles[j].changeNumber(controller, 0);
            }
            tiles[j].value = 0;
            tiles[i].value = resultValue;
          }
          break;
        }
      }
    }
    return didChange;
  }

  void _undoMove() {
    if (gameStates.isEmpty) return;
    GameState previousState = gameStates.removeLast();
    bool Function() mergeFn;
    switch (previousState.swipe) {
      case SwipeDirection.up:
        mergeFn = _mergeUp;
        break;
      case SwipeDirection.down:
        mergeFn = _mergeDown;
        break;
      case SwipeDirection.left:
        mergeFn = _mergeLeft;
        break;
      case SwipeDirection.right:
        mergeFn = _mergeRight;
        break;
    }
    setState(() {
      grid = previousState.previousGrid;
      mergeFn();
      controller.reverse(from: .99).then((_) {
        setState(() {
          grid = previousState.previousGrid;
          for (var t in gridTiles) {
            t.resetAnimations();
          }
        });
      });
    });
  }

  void _showGameOverDialog() {
    final t = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t.gameOver),
        content: Text("${t.finalScore}: $score"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _setupNewGame();
            },
            child: Text(t.restart),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    double padding = 16;
    double border = 4;
    double gridSize = MediaQuery.of(context).size.width - padding * 2;
    double tileSize = (gridSize - border * 2) / 4;

    List<Widget> stackItems = [
      ...gridTiles.map((t) => TileWidget(
            x: tileSize * t.x,
            y: tileSize * t.y,
            containerSize: tileSize,
            size: tileSize - border * 2,
            color: lightBrown,
          )),
      ...allTiles.map((tile) => AnimatedBuilder(
            animation: controller,
            builder: (context, child) => tile.animatedValue.value == 0
                ? const SizedBox()
                : TileWidget(
                    x: tileSize * tile.animatedX.value,
                    y: tileSize * tile.animatedY.value,
                    containerSize: tileSize,
                    size: (tileSize - border * 2) * tile.size.value,
                    color: numTileColor[tile.animatedValue.value] ?? tan,
                    child: Center(child: TileNumber(tile.animatedValue.value)),
                  ),
          )),
    ];

    return Scaffold(
      backgroundColor: tan,
      appBar: AppBar(
        title: Text("2048 - ${t.score(score)}"),
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const NewGamePage()),
            );
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Swiper(
              up: () => _merge(SwipeDirection.up),
              down: () => _merge(SwipeDirection.down),
              left: () => _merge(SwipeDirection.left),
              right: () => _merge(SwipeDirection.right),
              child: Container(
                height: gridSize,
                width: gridSize,
                padding: EdgeInsets.all(border),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(cornerRadius),
                  color: darkBrown,
                ),
                child: Stack(children: stackItems),
              ),
            ),
            const SizedBox(height: 20),
            BigButton(label: t.undo, color: numColor, onPressed: _undoMove),
            const SizedBox(height: 12),
            BigButton(label: t.restart, color: orange, onPressed: _setupNewGame),
          ],
        ),
      ),
    );
  }
}
