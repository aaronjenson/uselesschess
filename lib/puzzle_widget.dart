import 'package:audioplayers/audioplayers.dart';
import 'package:bishop/bishop.dart' as bishop;
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
    game.makeSquaresMove(move);
    var isCorrect =
        move.algebraic() == puzzle.board.toAlgebraic(puzzle.bestMove);
    sounds.play(AssetSource("${isCorrect ? "correct" : "move"}.mp3"));

    setState(() {
      playerState =
          isCorrect ? _PuzzleStates.guessedRight : _PuzzleStates.guessedWrong;
      state = game.squaresState(player);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      AspectRatio(
        aspectRatio: 1,
        child: Stack(children: [
          Padding(
            padding: const EdgeInsets.all(4.0),
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
      ),
      Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        OutlinedButton(onPressed: _newPuzzle, child: const Text('New Puzzle')),
        OutlinedButton(
            onPressed: _resetPuzzle, child: const Text('Reset Puzzle')),
        if (playerState == _PuzzleStates.guessedRight) const Text('Correct'),
        if (playerState == _PuzzleStates.guessedWrong)
          const Text('Incorrect, try again'),
      ])
    ]);
  }
}
