import 'package:bishop/bishop.dart' as bishop;

import 'evaluation.dart';
import 'puzzle.dart';

Future<Puzzle> getPuzzle(Evaluation eval) async {
  var game = bishop.Game(variant: bishop.Variant.standard());
  for (int i = 0; i < 24; i++) {
    game.makeRandomMove();
  }
  var move = await eval.bestMove(game);
  return Puzzle(board: game, bestMove: move);
}
