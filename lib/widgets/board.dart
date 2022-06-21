import 'dart:math' show pi;

import 'package:flutter/material.dart';
import 'package:tic_tac_toe_upgraded/game/game_utils.dart';
import 'package:tic_tac_toe_upgraded/objects/player_ai.dart';

import '../objects/square_object.dart';
import '../objects/player.dart';
import '../objects/theme.dart';
import '../stats.dart';
import 'complete_alert.dart';

class Board extends StatefulWidget {
  const Board(
      {super.key,
      this.board,
      this.gameType = GameType.singlePlayer,
      this.width = 3,
      this.pressHandler,
      this.player1Name = "player1",
      this.activePlayer,
      this.otherPlayer,
      this.time,
      this.rotate = false,
      this.navigator = "/"});

  /// A [List] of objects that will be placed on the [board]
  final List<SquareObject>? board;

  final GameType gameType;

  /// The [width] of the [board]
  final int width;

  /// The [Function] that will be called upon pressing one of the buttons on the [board]
  final Function? pressHandler;

  final String player1Name;

  /// The [Player] currently in control of the [board]
  final Player? activePlayer;

  /// The other [Player] in the game
  final Player? otherPlayer;

  final Stopwatch? time;

  /// Activate the rotate [Animation]
  final bool rotate;

  final String navigator;

  @override
  State<Board> createState() => _BoardState();
}

class _BoardState extends State<Board> {

  bool _rotate = false;

  // TODO test
  void findWinner(BuildContext context) {
    if (GameUtils.isComplete(
        widget.board!, widget.activePlayer!.usedValues, widget.otherPlayer?.usedValues)) {
      if (widget.time != null) {
        widget.time!.stop();
      }

      // TODO mark the winning area
      late final Player? winner;
      if (GameUtils.isThreeInARow(widget.board!)) {
        winner = widget.activePlayer;
      } else {
        winner = null;
      }

      String winnerString = winner != null ? widget.activePlayer.toString() : "No one";
      switch (widget.gameType) {
        case GameType.singlePlayer:
          GameUtils.setData(winner?.name == widget.player1Name, widget.time ?? Stopwatch(),
              gamesPlayed: StatData.gamesPlayed.sp,
              gamesWon: StatData.gamesWon.sp,
              timePlayed: StatData.timePlayed.sp);
          break;
        case GameType.localMultiplayer:
          GameUtils.setData(winner?.name == widget.player1Name, widget.time ?? Stopwatch(),
              gamesPlayed: StatData.gamesPlayed.lmp,
              gamesWon: StatData.gamesWon.lmp,
              timePlayed: StatData.timePlayed.lmp);
          break;
        default:
          GameUtils.setData(winner?.name == widget.player1Name, widget.time ?? Stopwatch(),
              gamesPlayed: StatData.gamesPlayed.mp,
              gamesWon: StatData.gamesWon.mp,
              timePlayed: StatData.timePlayed.mp);
      }

      showDialog(
          context: context,
          builder: (BuildContext context) => CompleteAlert(
                title: "$winnerString won the match",
                text: "Rematch?",
                navigator: widget.navigator,
              ));
    } else {
      GameUtils.switchTurn(widget.activePlayer!, widget.otherPlayer!);
      setState(() => _rotate = !_rotate); // FIXME state doesn't always update!
      if (widget.activePlayer is PlayerAI) {
        (widget.activePlayer as PlayerAI)
            .nextMove(widget.board!); // Starts the other players move
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: widget.width,
      shrinkWrap: true,
      children: widget.board!
          .map(
            (element) => _Square(
              object: element,
              activePlayer: widget.activePlayer,
              onPressed: widget.pressHandler,
              complete: findWinner,
              rotate: widget.rotate,
            ),
          )
          .toList(),
    );
  }
}

class _Square extends StatefulWidget {
  const _Square(
      {required this.object,
      this.activePlayer,
      this.otherPlayer,
      this.onPressed,
      required this.complete,
      this.rotate = false});

  final SquareObject object;

  final Player? activePlayer;

  final Player? otherPlayer;

  final Function? onPressed;

  final Function complete;

  /// Activate the rotate [Animation]
  final bool rotate;

  @override
  State<_Square> createState() => __SquareState();
}

class __SquareState extends State<_Square> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: GameUtils.rotationAnimation));
    _animation = Tween(begin: 0.0, end: pi).animate(_controller)
      ..addListener(() => setState(() => _animation.value));
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.rotate) {
      _controller.forward();
    } else if (_animation.value == pi) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handlePress() {
    late num value;
    if (widget.activePlayer != null) {
      value = widget.activePlayer!.activeNumber;
      if (widget.activePlayer != widget.object.player &&
          widget.object.value < value) {
        setState(() {
          widget.object.value = value;
          widget.object.player = widget.activePlayer;
        });

        widget.activePlayer?.usedValues[(value as int) - 1] = true;
        widget.activePlayer?.activeNumber = -1;

        widget.complete(context);
      }
    }
  }

  // TODO
  void handleDrag() {}

  @override
  Widget build(BuildContext context) {
    // Is true if [globalTheme] is [dark] or it's [system] and [system] is dark
    bool _isDark = MyTheme.isDark(context);
    return DragTarget(
      builder: (BuildContext context, List<dynamic> accepted,
          List<dynamic> rejected) {
        return Container(
          decoration: BoxDecoration(
            border: Border.symmetric(
                vertical: widget.object.index % 3 == 1
                    ? BorderSide(color: _isDark ? Colors.white : Colors.black)
                    : BorderSide.none,
                horizontal: widget.object.index >= 3 && widget.object.index <= 5
                    ? BorderSide(color: _isDark ? Colors.white : Colors.black)
                    : BorderSide.none),
          ),
          child: Center(
            child: Transform.rotate(
              angle: _animation.value,
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: widget.object.player?.color,
                  minimumSize: const Size(50, 50),
                  maximumSize: const Size(64, 64),
                ),
                child: Text(
                  "${widget.object.value}",
                  style: TextStyle(
                    color: widget.object.player != null
                        ? MyTheme.contrast(widget.object.player!.color)
                        : _isDark
                            ? Colors.white
                            : Colors.black,
                  ),
                ),
                onPressed: () => widget.activePlayer != null &&
                        widget.activePlayer!.activeNumber == -1
                    ? null
                    : _handlePress(),
              ),
            ),
          ),
        );
      },
      onWillAccept: (data) => [1, 2, 3, 4, 5].any((element) => data == element),
      onAccept: (data) {
        widget.onPressed!(widget.object.index,
            widget.activePlayer?.activeNumber, widget.activePlayer);
      },
    );
  }
}
