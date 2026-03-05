import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/camera_repository.dart';

class SetManualFocusPointParams {
  /// Normalised X offset in the preview frame (0.0 = left, 1.0 = right).
  final double x;

  /// Normalised Y offset in the preview frame (0.0 = top, 1.0 = bottom).
  final double y;

  const SetManualFocusPointParams({required this.x, required this.y});
}

class SetManualFocusPoint implements UseCase<void, SetManualFocusPointParams> {
  final CameraRepository _cameraRepository;

  const SetManualFocusPoint({required CameraRepository cameraRepository})
      : _cameraRepository = cameraRepository;

  @override
  Future<Either<Failure, void>> call(SetManualFocusPointParams params) async {
    return await _cameraRepository.setManualFocusPoint(
      x: params.x,
      y: params.y,
    );
  }
}
