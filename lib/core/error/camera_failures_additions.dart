// ─── Add to your existing core/error/failures.dart ─────────────────────────

// class CameraFailure extends Failure {
//   const CameraFailure(super.message);
// }

// Ensure your base Failure class looks like:
// abstract class Failure extends Equatable {
//   final String message;
//   const Failure(this.message);
//   @override
//   List<Object?> get props => [message];
// }

// ─── Add to your existing core/error/exceptions.dart ───────────────────────

// class CameraException implements Exception {
//   final String message;
//   const CameraException(this.message);
// }
