import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:game_2048/main.dart';
import 'game/tile.dart';
import 'game/grid_properties.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum SwipeDirection { up, down, left, right }

class GameState {
  final List<List<Tile>> _previousGrid;
  final SwipeDirection swipe;

  GameState(List<List<Tile>> previousGrid, this.swipe)
      : _previousGrid = previousGrid;

  List<List<Tile>> get previousGrid => _previousGrid
      .map((row) => row.map((tile) => tile.copy()).toList())
      .toList();
}

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  bool _isAnimating = false;

  List<List<Tile>> grid =
      List.generate(4, (y) => List.generate(4, (x) => Tile(x, y, 0)));
  List<GameState> gameStates = [];
  List<Tile> toAdd = [];

  int score = 0;
  int bestScore = 0;

  Iterable<Tile> get gridTiles => grid.expand((e) => e);
  Iterable<Tile> get allTiles => [gridTiles, toAdd].expand((e) => e);
  List<List<Tile>> get gridCols =>
      List.generate(4, (x) => List.generate(4, (y) => grid[y][x]));

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        duration: const Duration(milliseconds: 200), vsync: this);
    controller.addStatusListener((status) {
      _loadBestScore();
      if (status == AnimationStatus.completed) {
        setState(() {
          for (var e in toAdd) {
            grid[e.y][e.x].value = e.value;
          }
          for (var t in gridTiles) {
            t.resetAnimations();
          }
          toAdd.clear();
          _isAnimating = false;
        });

        if (!_hasValidMoves()) {
          _showGameOverDialog();
        }
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
      if (score > bestScore) bestScore = score;
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

  Future<void> _loadBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    final localBest = prefs.getInt('best_score') ?? 0;
    User? user;
    if(connectionNotifier.value!=ConnectionStatus.online){
     user = FirebaseAuth.instance.currentUser;
    }
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final firebaseBest = doc.data()?['bestScore'] ?? 0;
      final maxScore = (firebaseBest is int && firebaseBest > localBest)
          ? firebaseBest
          : localBest;

      setState(() {
        bestScore = maxScore;
      });
      await _saveBestScore(maxScore); // Sync local with Firebase if needed
    } else {
      setState(() {
        bestScore = localBest;
      });
    }
  }

  Future<void> _saveBestScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('best_score', score);
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
    if (_isAnimating) return;

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

    bool didMove = mergeFn();
    if (didMove) {
      setState(() {
        _isAnimating = true;
        gameStates.add(GameState(gridBeforeSwipe, direction));
        _addNewTiles([2]);
        controller.forward(from: 0);
      });
    }
  }

  bool _hasValidMoves() {
    return gridTiles.any((t) => t.value == 0) ||
        _canMerge(grid) ||
        _canMerge(gridCols);
  }

  bool _canMerge(List<List<Tile>> rows) {
    for (var row in rows) {
      for (int i = 0; i < row.length - 1; i++) {
        if (row[i].value == row[i + 1].value) return true;
      }
    }
    return false;
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

  bool _mergeLeft() {
    bool changed = false;
    for (int y = 0; y < 4; y++) {
      if (_mergeTiles(grid[y])) changed = true;
    }
    return changed;
  }

  bool _mergeRight() {
    bool changed = false;
    for (int y = 0; y < 4; y++) {
      List<Tile> row = grid[y].reversed.toList();
      if (_mergeTiles(row)) changed = true;
      grid[y] = row.reversed.toList();
    }
    return changed;
  }

  bool _mergeUp() {
    bool changed = false;
    for (int x = 0; x < 4; x++) {
      List<Tile> col = List.generate(4, (y) => grid[y][x]);
      if (_mergeTiles(col)) changed = true;
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
      if (_mergeTiles(col)) changed = true;
      List<Tile> fixed = col.reversed.toList();
      for (int y = 0; y < 4; y++) {
        grid[y][x] = fixed[y];
      }
    }
    return changed;
  }

  void _undoMove() {
    if (_isAnimating || gameStates.isEmpty) return;
    GameState previousState = gameStates.removeLast();
    setState(() {
      grid = previousState.previousGrid;
      toAdd.clear();
      controller.forward(from: 0);
      for (var t in gridTiles) {
        t.resetAnimations();
      }
    });
  }

  void _showGameOverDialog() async {
    final t = AppLocalizations.of(context)!;
    final navigator = Navigator.of(context);
    if (score > bestScore) {
      setState(() {
        bestScore = score;
      });
      await _saveBestScore(score); // Save locally
      await _uploadBestScoreToFirebase(score); // Save remotely
    }
    if (mounted) {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(t.gameOver),
          content: Text("${t.finalScore}: $score"),
          actions: [
            TextButton(
              onPressed: () {
                navigator.pop();
                _setupNewGame();
              },
              child: Text(t.restart),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _uploadBestScoreToFirebase(int score) async {
    if(connectionNotifier.value!=ConnectionStatus.online) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc =
        FirebaseFirestore.instance.collection('users').doc(user.uid);

    try {
      await userDoc.set({'bestScore': score}, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Failed to upload best score: $e");
    }
  }

  Widget _buildScoreBox(String label, int value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(label.toUpperCase(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white)),
          Text('$value',
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushReplacementNamed('/main');
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                "${t.scoreLabel}: ${NumberFormat.decimalPattern().format(score)}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.brown,
                ),
              ),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final screenHeight = constraints.maxHeight;

            const topPadding = 10.0;
            const titleHeight = 60.0;
            const scoresHeight = 60.0;
            const buttonsHeight = 60.0;
            const spacing = 60.0; // for spacing between rows
            const totalReservedHeight = topPadding +
                titleHeight +
                scoresHeight +
                buttonsHeight +
                spacing;

            final availableHeightForGrid = screenHeight - totalReservedHeight;

            final gridSize = screenWidth < availableHeightForGrid
                ? screenWidth - 32 // padding
                : availableHeightForGrid;

            final tileSize = (gridSize - 8) / 4; // 8 = total border padding

            List<Widget> stackItems = [
              ...gridTiles.map((t) => TileWidget(
                    x: tileSize * t.x,
                    y: tileSize * t.y,
                    containerSize: tileSize,
                    size: tileSize - 8,
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
                            size: (tileSize - 8) * tile.size.value,
                            color:
                                numTileColor[tile.animatedValue.value] ?? tan,
                            child: Center(
                                child: TileNumber(tile.animatedValue.value)),
                          ),
                  )),
            ];

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: topPadding),
                  Text(
                    "2048",
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildScoreBox(t.scoreLabel, score),
                      _buildScoreBox(t.bestLabel, bestScore),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _iconButton(Icons.undo, _undoMove),
                      const SizedBox(width: 8),
                      _iconButton(Icons.refresh, _setupNewGame),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Swiper(
                    up: () => _merge(SwipeDirection.up),
                    down: () => _merge(SwipeDirection.down),
                    left: () => _merge(SwipeDirection.left),
                    right: () => _merge(SwipeDirection.right),
                    child: Container(
                      height: gridSize,
                      width: gridSize,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(cornerRadius),
                        color: darkBrown,
                      ),
                      child: Stack(children: stackItems),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _iconButton(IconData icon, VoidCallback onPressed) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.85),
        borderRadius: BorderRadius.circular(6),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }
}
