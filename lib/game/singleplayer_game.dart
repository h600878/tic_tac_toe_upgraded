import 'package:flutter/material.dart';
import 'package:tic_tac_toe_upgraded/game/game.dart';
import 'package:tic_tac_toe_upgraded/game/game_utils.dart';
import 'package:tic_tac_toe_upgraded/main.dart';
import 'package:tic_tac_toe_upgraded/objects/player_ai.dart';
import 'package:tic_tac_toe_upgraded/objects/theme.dart';
import 'package:tic_tac_toe_upgraded/stats.dart';
import 'package:tic_tac_toe_upgraded/widgets/complete_alert.dart';
import 'package:tic_tac_toe_upgraded/widgets/select_buttons.dart';

import '../objects/player.dart';
import '../widgets/board.dart';
import '../widgets/layout.dart';
import '../objects/square_object.dart';

class SinglePlayerGamePage extends StatefulWidget {
  const SinglePlayerGamePage({super.key});

  @override
  State<SinglePlayerGamePage> createState() => _SinglePlayerGamePageState();
}

class _SinglePlayerGamePageState extends State<SinglePlayerGamePage>
    implements Game {
  @override
  List<SquareObject> board = List.generate(
      GameUtils.boardLength, (index) => SquareObject(index: index));

  late Player _player;
  late PlayerAI _playerAI;
  final List<Player> _players = [Player(), PlayerAI()];
  final _time = Stopwatch(); // Used to time the matches

  _SinglePlayerGamePageState() {
    _player = Player(
        name: "Player1", color: MyTheme.player1Color.color, isTurn: true);
    _playerAI = PlayerAI(name: "AI", color: MyTheme.player2Color.color);

    _players[0] = _player;
    _players[1] = _playerAI;

    _time.start();
  }

  @override
  void updateState([VoidCallback? fun]) => setState(() => fun);

  @override
  void switchTurn() {
    GameUtils.switchTurn(_players);
    if (_playerAI.isTurn) {
      _playerAI.nextMove(board); // Starts the other players move
    }
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      title: "Single-player game",
      body: Column(
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Board(
                board: board,
                updateState: updateState,
                switchTurn: switchTurn,
                players: _players,
                ai: _playerAI,
                squareSize: 100,
                navigator: Navigate.singlePlayer.route,
                time: _time,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 50),
            child: SelectButtons(
              player: _player,
              offsetOnActivate: const Offset(0, -20),
            ),
          ),
        ],
      ),
    );
  }
}
