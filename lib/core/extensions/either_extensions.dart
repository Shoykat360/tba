import 'package:dartz/dartz.dart';

extension EitherExtensions<L, R> on Either<L, R> {
  R? get rightOrNull => fold((_) => null, (r) => r);
  L? get leftOrNull => fold((l) => l, (_) => null);
  bool get isRight => fold((_) => false, (_) => true);
  bool get isLeft => fold((_) => true, (_) => false);
}
