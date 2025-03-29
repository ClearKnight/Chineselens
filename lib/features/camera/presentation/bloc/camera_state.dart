import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';

abstract class CameraState extends Equatable {
  const CameraState();

  @override
  List<Object?> get props => [];
}

class CameraInitial extends CameraState {
  const CameraInitial();
}

class CameraInitializing extends CameraState {
  const CameraInitializing();
}

class CameraInitialized extends CameraState {
  final CameraController controller;
  final double minZoomLevel;
  final double maxZoomLevel;
  final double currentZoomLevel;
  final FlashMode flashMode;

  const CameraInitialized({
    required this.controller,
    required this.minZoomLevel,
    required this.maxZoomLevel,
    required this.currentZoomLevel,
    required this.flashMode,
  });

  @override
  List<Object?> get props => [
        controller,
        minZoomLevel,
        maxZoomLevel,
        currentZoomLevel,
        flashMode,
      ];

  CameraInitialized copyWith({
    CameraController? controller,
    double? minZoomLevel,
    double? maxZoomLevel,
    double? currentZoomLevel,
    FlashMode? flashMode,
  }) {
    return CameraInitialized(
      controller: controller ?? this.controller,
      minZoomLevel: minZoomLevel ?? this.minZoomLevel,
      maxZoomLevel: maxZoomLevel ?? this.maxZoomLevel,
      currentZoomLevel: currentZoomLevel ?? this.currentZoomLevel,
      flashMode: flashMode ?? this.flashMode,
    );
  }
}

class TakingPicture extends CameraState {
  const TakingPicture();
}

class PictureTaken extends CameraState {
  final String imagePath;

  const PictureTaken({required this.imagePath});

  @override
  List<Object?> get props => [imagePath];
}

class GalleryImageSelected extends CameraState {
  final String imagePath;

  const GalleryImageSelected({required this.imagePath});

  @override
  List<Object?> get props => [imagePath];
}

class CameraError extends CameraState {
  final String errorMessage;

  const CameraError({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}
