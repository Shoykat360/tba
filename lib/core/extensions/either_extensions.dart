import 'package:dartz/dartz.dart';

/*extension EitherExtensions<L, R> on Either<L, R> {
  /// Extracts the Right value after an `isLeft()` early-return guard.
  ///
  /// Throws [StateError] if called on a Left — but this is unreachable in
  /// practice because all callers guard with `if (result.isLeft()) return;`
  /// before calling this. It is strictly safer than using `fold` with a throw
  /// lambda because the name makes the intent explicit.
  R get rightOrThrow => fold(
        (_) => throw StateError(
          'rightOrThrow called on Left. Guard with isLeft() before calling.',
        ),
        (r) => r,
      );

  /// Extracts the Left value after an `isRight()` early-return guard.
  L get leftOrThrow => fold(
        (l) => l,
        (_) => throw StateError(
          'leftOrThrow called on Right. Guard with isRight() before calling.',
        ),
      );
}*/

extension EitherExtensions<L, R> on Either<L, R> {
  R? get rightOrNull => fold((_) => null, (r) => r);
  L? get leftOrNull => fold((l) => l, (_) => null);
  bool get isRight => fold((_) => false, (_) => true);
  bool get isLeft => fold((_) => true, (_) => false);
}