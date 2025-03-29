import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';

abstract class CameraEvent extends Equatable {
  const CameraEvent();

  @override
  List<Object?> get props => [];
}

class InitializeCameraRequested extends CameraEvent {
  final bool? useRearCamera;

  const InitializeCameraRequested({this.useRearCamera = true});

  @override
  List<Object?> get props => [useRearCamera];
}

class TakePictureRequested extends CameraEvent {
  const TakePictureRequested();
}

class SwitchCameraRequested extends CameraEvent {
  final bool useRearCamera;

  const SwitchCameraRequested({required this.useRearCamera});

  @override
  List<Object?> get props => [useRearCamera];
}

class SetFlashModeRequested extends CameraEvent {
  final FlashMode flashMode;

  const SetFlashModeRequested({required this.flashMode});

  @override
  List<Object?> get props => [flashMode];
}

class SetZoomLevelRequested extends CameraEvent {
  final double zoomLevel;

  const SetZoomLevelRequested({required this.zoomLevel});

  @override
  List<Object?> get props => [zoomLevel];
}

class PickFromGalleryRequested extends CameraEvent {
  const PickFromGalleryRequested();
}
