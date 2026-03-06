import 'package:camera/camera.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/camera_repository.dart';
import 'package:flutter/material.dart';
class SetManualFocusPointParams {
  final CameraController controller;
  final Offset point;
  SetManualFocusPointParams({required this.controller, required this.point});
}

class SetManualFocusPoint {
  final CameraRepository repository;
  SetManualFocusPoint(this.repository);

  Future<Either<Failure, void>> call(SetManualFocusPointParams params) {
    return repository.setFocusPoint(params.controller, params.point);
  }
}
