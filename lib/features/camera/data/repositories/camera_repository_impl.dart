/*
import 'package:camera/camera.dart' hide CameraException;
import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/camera_configuration.dart';
import '../../domain/entities/captured_image.dart';
import '../../domain/repositories/camera_repository.dart';
import '../datasources/camera_local_datasource.dart';
import 'package:flutter/material.dart';
class CameraRepositoryImpl implements CameraRepository {
  final CameraLocalDatasource localDatasource;
  final Uuid uuid;

  CameraRepositoryImpl({
    required this.localDatasource,
    required this.uuid,
  });

  @override
  Future<Either<Failure, CameraController>> initializeCamera() async {
    try {
      final cameras = await localDatasource.getAvailableCameras();
      if (cameras.isEmpty) {
        return Left(CameraFailure('No cameras available on this device'));
      }
      // Use the first back camera available
      final backCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = await localDatasource.initializeCameraController(backCamera);
      return Right(controller);
    } on CameraException catch (e) {
      return Left(CameraFailure(e.message ?? 'Camera initialization failed'));
    } catch (e) {
      return Left(CameraFailure('Unexpected camera error: $e'));
    }
  }

  @override
  Future<Either<Failure, CapturedImage>> captureImageAndStoreLocally(
      CameraController controller) async {
    try {
      final batchId = uuid.v4();
      final model = await localDatasource.captureAndSave(controller, batchId);
      return Right(model.toEntity());
    } on CameraException catch (e) {
      return Left(CameraFailure(e.message ?? 'Capture failed'));
    }
  }

  @override
  Future<Either<Failure, CameraConfiguration>> getCameraConfiguration(
      CameraController controller) async {
    try {
      final minZoom = await localDatasource.getMinZoom(controller);
      final maxZoom = await localDatasource.getMaxZoom(controller);

      // Build zoom presets based on available range
      final presets = <double>[];
      if (minZoom <= 0.5 && maxZoom >= 0.5) presets.add(0.5);
      if (maxZoom >= 1.0) presets.add(1.0);
      if (maxZoom >= 2.0) presets.add(2.0);
      if (maxZoom >= 3.0) presets.add(3.0);
      if (presets.isEmpty) presets.add(1.0);

      return Right(CameraConfiguration(
        minZoom: minZoom,
        maxZoom: maxZoom,
        currentZoom: 1.0,
        availableZoomPresets: presets,
        isFocusSupported: true,
      ));
    } catch (e) {
      return Left(CameraFailure('Failed to get camera config: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> setZoomLevel(
      CameraController controller, double zoom) async {
    try {
      await controller.setZoomLevel(zoom);
      return const Right(null);
    } catch (e) {
      return Left(CameraFailure('Failed to set zoom: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> setFocusPoint(
      CameraController controller, Offset point) async {
    try {
      await controller.setFocusMode(FocusMode.auto);
      await controller.setFocusPoint(point);
      return const Right(null);
    } catch (e) {
      return Left(CameraFailure('Failed to set focus: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> disposeCamera(CameraController controller) async {
    try {
      await controller.dispose();
      return const Right(null);
    } catch (e) {
      return Left(CameraFailure('Failed to dispose camera: $e'));
    }
  }
}
*/

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/camera_configuration.dart';
import '../../domain/entities/captured_image.dart';
import '../../domain/repositories/camera_repository.dart';
import '../datasources/camera_local_datasource.dart';

class CameraRepositoryImpl implements CameraRepository {
  final CameraLocalDatasource localDatasource;
  final Uuid uuid;

  CameraRepositoryImpl({
    required this.localDatasource,
    required this.uuid,
  });

  @override
  Future<Either<Failure, CameraController>> initializeCamera() async {
    try {
      final cameras = await localDatasource.getAvailableCameras();
      if (cameras.isEmpty) {
        return Left(CameraFailure('No cameras available on this device'));
      }
      final backCamera = cameras.firstWhere(
            (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller =
      await localDatasource.initializeCameraController(backCamera);
      return Right(controller);
    } on CameraException catch (e) {
      return Left(CameraFailure(e.description ?? 'Camera initialization failed'));
    } catch (e) {
      return Left(CameraFailure('Unexpected camera error: $e'));
    }
  }

  @override
  Future<Either<Failure, CapturedImage>> captureImageAndStoreLocally(
      CameraController controller) async {
    try {
      // Each captured image gets its own unique batchId
      // This fixes "all images show same batch name" in the pending list
      final batchId = uuid.v4();
      final model = await localDatasource.captureAndSave(controller, batchId);
      return Right(model.toEntity());
    } on CameraException catch (e) {
      return Left(CameraFailure(e.description ?? 'Capture failed'));
    } catch (e) {
      return Left(CameraFailure('Capture unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, CameraConfiguration>> getCameraConfiguration(
      CameraController controller) async {
    try {
      final minZoom = await localDatasource.getMinZoom(controller);
      final maxZoom = await localDatasource.getMaxZoom(controller);

      final presets = <double>[];
      if (minZoom <= 0.5 && maxZoom >= 0.5) presets.add(0.5);
      if (maxZoom >= 1.0) presets.add(1.0);
      if (maxZoom >= 2.0) presets.add(2.0);
      if (maxZoom >= 3.0) presets.add(3.0);
      if (presets.isEmpty) presets.add(1.0);

      return Right(CameraConfiguration(
        minZoom: minZoom,
        maxZoom: maxZoom,
        currentZoom: 1.0,
        availableZoomPresets: presets,
        isFocusSupported: true,
      ));
    } catch (e) {
      return Left(CameraFailure('Failed to get camera config: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> setZoomLevel(
      CameraController controller, double zoom) async {
    try {
      await controller.setZoomLevel(zoom);
      return const Right(null);
    } on CameraException catch (e) {
      return Left(CameraFailure(e.description ?? 'Failed to set zoom'));
    } catch (e) {
      return Left(CameraFailure('Failed to set zoom: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> setFocusPoint(
      CameraController controller, Offset point) async {
    try {
      await controller.setFocusMode(FocusMode.auto);
      await controller.setFocusPoint(point);
      return const Right(null);
    } on CameraException catch (e) {
      return Left(CameraFailure(e.description ?? 'Failed to set focus'));
    } catch (e) {
      return Left(CameraFailure('Failed to set focus: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> disposeCamera(
      CameraController controller) async {
    try {
      await controller.dispose();
      return const Right(null);
    } on CameraException catch (e) {
      return Left(CameraFailure(e.description ?? 'Failed to dispose camera'));
    } catch (e) {
      return Left(CameraFailure('Failed to dispose: $e'));
    }
  }
}