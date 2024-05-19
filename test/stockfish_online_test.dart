import 'package:bishop/bishop.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uselesschess/stockfish_online.dart';

void main() {
  group("Stockfish Online Evaluation", () {
    test("should fetch best move", () async {
      var eval = StockfishOnline();
      var game = Game();
      var best = await eval.bestMove(game);
      expect(best, game.getMove("e2e4"));
    });
  });
}