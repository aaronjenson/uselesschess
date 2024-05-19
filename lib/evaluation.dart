import 'package:bishop/bishop.dart';

abstract class Evaluation {
  Future<Move> bestMove(Game game, {int depth});
}
