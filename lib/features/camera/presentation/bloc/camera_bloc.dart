import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'camera_event.dart';
import 'camera_state.dart';

class CameraBloc extends Bloc<CameraEvent, CameraState> {
  final ImagePicker _imagePicker = ImagePicker();
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];

  CameraBloc() : super(const CameraInitial()) {
    on<InitializeCameraRequested>(_onInitializeCamera);
    on<TakePictureRequested>(_onTakePicture);
    on<SwitchCameraRequested>(_onSwitchCamera);
    on<SetFlashModeRequested>(_onSetFlashMode);
    on<SetZoomLevelRequested>(_onSetZoomLevel);
    on<PickFromGalleryRequested>(_onPickFromGallery);
  }

  @override
  Future<void> close() {
    _cameraController?.dispose();
    return super.close();
  }

  Future<void> _onInitializeCamera(
    InitializeCameraRequested event,
    Emitter<CameraState> emit,
  ) async {
    emit(const CameraInitializing());

    try {
      // 获取可用相机列表
      _cameras = await availableCameras();

      if (_cameras.isEmpty) {
        emit(const CameraError(errorMessage: '没有可用的相机'));
        return;
      }

      // 选择相机（前置或后置）
      final CameraDescription cameraDescription = _getCameraDescription(
        useRear: event.useRearCamera ?? true,
      );

      // 初始化相机控制器
      final CameraController controller = CameraController(
        cameraDescription,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await controller.initialize();

      // 获取缩放级别范围
      final double minZoom = await controller.getMinZoomLevel();
      final double maxZoom = await controller.getMaxZoomLevel();
      const double initialZoom = 1.0;

      // 设置初始闪光灯模式
      await controller.setFlashMode(FlashMode.off);

      _cameraController = controller;

      if (!isClosed) {
        emit(CameraInitialized(
          controller: controller,
          minZoomLevel: minZoom,
          maxZoomLevel: maxZoom,
          currentZoomLevel: initialZoom,
          flashMode: FlashMode.off,
        ));
      }
    } catch (e) {
      emit(CameraError(errorMessage: '相机初始化失败: $e'));
    }
  }

  Future<void> _onTakePicture(
    TakePictureRequested event,
    Emitter<CameraState> emit,
  ) async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      emit(const CameraError(errorMessage: '相机未初始化'));
      return;
    }

    try {
      emit(const TakingPicture());

      // 获取临时目录路径
      final Directory tempDir = await getTemporaryDirectory();
      final String filePath = path.join(
        tempDir.path,
        'image_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      // 拍照并保存到临时文件
      final XFile imageFile = await _cameraController!.takePicture();
      await imageFile.saveTo(filePath);

      emit(PictureTaken(imagePath: filePath));
    } catch (e) {
      emit(CameraError(errorMessage: '拍照失败: $e'));
    }
  }

  Future<void> _onSwitchCamera(
    SwitchCameraRequested event,
    Emitter<CameraState> emit,
  ) async {
    if (_cameras.isEmpty) {
      emit(const CameraError(errorMessage: '没有可用的相机'));
      return;
    }

    try {
      // 释放当前相机控制器
      await _cameraController?.dispose();

      // 获取新的相机描述
      final CameraDescription cameraDescription = _getCameraDescription(
        useRear: event.useRearCamera,
      );

      // 创建新的相机控制器
      final CameraController controller = CameraController(
        cameraDescription,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await controller.initialize();

      // 获取缩放级别范围
      final double minZoom = await controller.getMinZoomLevel();
      final double maxZoom = await controller.getMaxZoomLevel();

      // 保持之前的闪光灯模式
      FlashMode flashMode = FlashMode.off;
      if (state is CameraInitialized) {
        flashMode = (state as CameraInitialized).flashMode;
        await controller.setFlashMode(flashMode);
      }

      _cameraController = controller;

      if (!isClosed) {
        emit(CameraInitialized(
          controller: controller,
          minZoomLevel: minZoom,
          maxZoomLevel: maxZoom,
          currentZoomLevel: 1.0,
          flashMode: flashMode,
        ));
      }
    } catch (e) {
      emit(CameraError(errorMessage: '切换相机失败: $e'));
    }
  }

  Future<void> _onSetFlashMode(
    SetFlashModeRequested event,
    Emitter<CameraState> emit,
  ) async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      emit(const CameraError(errorMessage: '相机未初始化'));
      return;
    }

    try {
      await _cameraController!.setFlashMode(event.flashMode);

      if (state is CameraInitialized) {
        final currentState = state as CameraInitialized;
        emit(currentState.copyWith(flashMode: event.flashMode));
      }
    } catch (e) {
      emit(CameraError(errorMessage: '设置闪光灯模式失败: $e'));
    }
  }

  Future<void> _onSetZoomLevel(
    SetZoomLevelRequested event,
    Emitter<CameraState> emit,
  ) async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      emit(const CameraError(errorMessage: '相机未初始化'));
      return;
    }

    try {
      await _cameraController!.setZoomLevel(event.zoomLevel);

      if (state is CameraInitialized) {
        final currentState = state as CameraInitialized;
        emit(currentState.copyWith(currentZoomLevel: event.zoomLevel));
      }
    } catch (e) {
      emit(CameraError(errorMessage: '设置缩放级别失败: $e'));
    }
  }

  Future<void> _onPickFromGallery(
    PickFromGalleryRequested event,
    Emitter<CameraState> emit,
  ) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );

      if (image != null) {
        emit(GalleryImageSelected(imagePath: image.path));
        // 选择图片后立即处理
        emit(PictureTaken(imagePath: image.path));
      }
    } catch (e) {
      emit(CameraError(errorMessage: '从相册选择图片失败: $e'));
    }
  }

  CameraDescription _getCameraDescription({required bool useRear}) {
    return _cameras.firstWhere(
      (camera) => useRear
          ? camera.lensDirection == CameraLensDirection.back
          : camera.lensDirection == CameraLensDirection.front,
      orElse: () => _cameras.first,
    );
  }
}
