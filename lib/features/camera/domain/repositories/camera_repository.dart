import 'package:camera/camera.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import '../../../../core/error/failures.dart';
import '../entities/camera_configuration.dart';
import '../entities/captured_image.dart';

abstract class CameraRepository {
  Future<Either<Failure, CameraController>> initializeCamera();

  Future<Either<Failure, CapturedImage>> captureImageAndStoreLocally(
      CameraController controller);

  Future<Either<Failure, CameraConfiguration>> getCameraConfiguration(
      CameraController controller);

  Future<Either<Failure, void>> setZoomLevel(
      CameraController controller, double zoom);

  Future<Either<Failure, void>> setFocusPoint(
      CameraController controller, Offset point);

  Future<Either<Failure, void>> disposeCamera(CameraController controller);
}
