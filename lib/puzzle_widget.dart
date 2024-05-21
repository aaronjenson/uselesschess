import 'package:audioplayers/audioplayers.dart';
import 'package:bishop/bishop.dart' as bishop;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:square_bishop/square_bishop.dart';
import 'package:squares/squares.dart' as squares;

import 'evaluation.dart';
import 'puzzle.dart';
import 'puzzle_gen.dart';
import 'stockfish_online.dart';

class PuzzleWidget extends StatefulWidget {
  const PuzzleWidget({super.key});

  @override
  State<PuzzleWidget> createState() => _PuzzleWidgetState();
}

enum _PuzzleStates {
  loading,
  ready,
  guessedWrong,
  guessedRight,
}

class _PuzzleWidgetState extends State<PuzzleWidget> {
  _PuzzleStates playerState = _PuzzleStates.loading;
  late bishop.Game game;
  late Puzzle puzzle;
  int player = squares.Squares.white;
  SquaresState state = bishop.Game().squaresState(squares.Squares.white);
  List<(bool, bishop.Move)> guesses = [];

  Evaluation eval = StockfishOnline();
  AudioPlayer sounds = AudioPlayer();

  @override
  void initState() {
    _newPuzzle();
    super.initState();
  }

  void _newPuzzle() {
    setState(() => playerState = _PuzzleStates.loading);
    getPuzzle(eval).then((puz) {
      setState(() {
        guesses = [];
        puzzle = puz;
        game = bishop.Game(
            variant: bishop.Variant.standard(), fen: puzzle.board.fen);
        player = game.turn;
        state = game.squaresState(player);
        playerState = _PuzzleStates.ready;
      });
    });
  }

  void _resetPuzzle() {
    setState(() {
      game = bishop.Game(
          variant: bishop.Variant.standard(), fen: puzzle.board.fen);
      player = game.turn;
      state = game.squaresState(player);
      playerState = _PuzzleStates.ready;
    });
  }

  void _onMove(squares.Move move) {
    var bmove = puzzle.board.getMove(move.algebraic());
    if (bmove == null) throw Exception("Got null move in _onMove");
    game.makeMove(bmove);
    var isCorrect =
        move.algebraic() == puzzle.board.toAlgebraic(puzzle.bestMove);
    sounds.play(AssetSource("${isCorrect ? "correct" : "move"}.mp3"));

    setState(() {
      guesses.insert(0, (isCorrect, bmove));
      playerState =
          isCorrect ? _PuzzleStates.guessedRight : _PuzzleStates.guessedWrong;
      state = game.squaresState(player);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      if (constraints.maxHeight > constraints.maxWidth) {
        return Column(children: [
          buildBoard(),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            if (guesses.isNotEmpty) buildGuessList(),
            buildButtons()
          ])
        ]);
      } else {
        return Row(children: [
          buildBoard(),
          Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.center, children: [
            if (guesses.isNotEmpty) buildGuessList(),
            buildButtons()
          ])
        ]);
      }
    });
  }

  Widget buildButtons() {
    return Column(children: [
      OutlinedButton(
          onPressed: enabledNewPuzzle() ? _newPuzzle : null,
          child: const Text('New Puzzle')),
      OutlinedButton(
          onPressed: enabledResetPuzzle() ? _resetPuzzle : null,
          child: const Text('Reset Puzzle')),
    ]);
  }

  bool enabledResetPuzzle() {
    return playerState != _PuzzleStates.ready &&
        playerState != _PuzzleStates.loading;
  }

  bool enabledNewPuzzle() => playerState != _PuzzleStates.loading;

  Widget buildGuessList() {
    return Column(
      children: [
        for (var guess in guesses)
          Row(children: [
            if (guess.$1)
              const Icon(Icons.check_circle_outline, color: Colors.green),
            if (!guess.$1) const Icon(Icons.highlight_off, color: Colors.red),
            Text(puzzle.board.toAlgebraic(guess.$2)),
          ])
      ],
    );
  }

  BoxDecoration? getBorder() {
    Color color;
    switch (playerState) {
      case _PuzzleStates.guessedRight:
        color = Colors.green;
      case _PuzzleStates.guessedWrong:
        color = Colors.red;
      default:
        color = Colors.transparent;
    }
    return BoxDecoration(border: Border.all(color: color, width: 4));
  }

  Widget buildBoard() {
    return AspectRatio(
      aspectRatio: 1,
      child: Stack(children: [
        Container(
          margin: const EdgeInsets.all(2.0),
          decoration: getBorder(),
          child: squares.BoardController(
            state: state.board,
            playState: state.state,
            pieceSet: squares.PieceSet.merida(),
            moves: playerState == _PuzzleStates.ready ? state.moves : [],
            theme: squares.BoardTheme.brown,
            onMove: _onMove,
          ),
        ),
        if (playerState == _PuzzleStates.loading)
          const Opacity(
              opacity: 0.8,
              child: ModalBarrier(
                dismissible: false,
                color: Colors.black,
              )),
        if (playerState == _PuzzleStates.loading)
          const Center(child: CircularProgressIndicator())
      ]),
    );
  }
}
