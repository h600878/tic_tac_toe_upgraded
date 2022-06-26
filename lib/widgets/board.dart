import 'dart:math' show pi;

import 'package:flutter/material.dart';
import 'package:tic_tac_toe_upgraded/game/game_utils.dart';

import '../objects/square_object.dart';
import '../objects/player.dart';
import '../objects/theme.dart';

class Board extends StatelessWidget {
  const Board(
      {super.key,
      this.board,
      this.width = 3,
      this.onPressed,
      this.activePlayer,
      this.rotate = false});

  /// A [List] of objects that will be placed on the [board]
  final List<dynamic>? board;

  /// The [width] of the [board]
  final int width;

  /// The [Function] that will be called upon pressing one of the buttons on the [board]
  final Function? onPressed;

  /// The [Player] currently in control of the [board]
  final Player? activePlayer;

  /// If 'true' all the squares in the board will rotate 180 degrees immediately
  final bool rotate;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: width,
      shrinkWrap: true,
      children: board!
          .map(
            (element) => _Square(
              object: element,
              activePlayer: activePlayer,
              onPressed: onPressed,
              rotate: rotate,
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
      this.onPressed,
      this.rotate = false});

  /// An [object] containing data of the square
  final SquareObject object;

  /// The currently playing [Player]
  final Player? activePlayer;

  /// The [Function] that's called when a square is pressed, or a [Draggable] is dropped on it
  final Function? onPressed;

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
      duration: const Duration(milliseconds: GameUtils.rotationAnimation),
    );
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
                    : widget.onPressed!(widget.object.index,
                        widget.activePlayer?.activeNumber, widget.activePlayer),
              ),
            ),
          ),
        );
      },
      onWillAccept: (data) => [1, 2, 3, 4, 5].any((element) => element == data),
      onAccept: widget.onPressed != null
          ? (data) =>
              widget.onPressed!(widget.object.index, data, widget.activePlayer)
          : null,
    );
  }
}
