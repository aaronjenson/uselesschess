import 'dart:convert';

import 'package:bishop/bishop.dart';
import 'package:http/http.dart' as http;

import 'evaluation.dart';

const defaultDepth = 15;

class StockfishOnline extends Evaluation {
  @override
  Future<Move> bestMove(Game game, {int depth = defaultDepth}) async {
    Move? move;
    var response = await http.get(Uri.https("stockfish.online", "/api/s/v2.php",
        {"fen": game.fen, "depth": depth.toString()}));
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      move = game.getMove((body["continuation"] as String).split(' ')[0]);
    }
    if (move != null) {
      return move;
    }
    throw Exception("Could not get best move for board ${game.fen}");
  }
}
