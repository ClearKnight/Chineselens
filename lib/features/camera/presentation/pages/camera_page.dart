import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera/camera.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:chinese_lens/config/constants.dart';
import 'package:chinese_lens/features/camera/presentation/bloc/bloc.dart';

class CameraPage extends StatelessWidget {
  const CameraPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CameraBloc(),
      child: const CameraView(),
    );
  }
}

class CameraView extends StatefulWidget {
  const CameraView({Key? key}) : super(key: key);

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> with WidgetsBindingObserver {
  CameraController? _controller;
  bool _isCameraInitialized = false;
  bool _isRearCameraSelected = true;
  double _minZoomLevel = 1.0;
  double _maxZoomLevel = 1.0;
  double _currentZoomLevel = 1.0;
  FlashMode _flashMode = FlashMode.off;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    context.read<CameraBloc>().add(const InitializeCameraRequested());
  }

  void _takePicture() {
    if (_controller != null && _controller!.value.isInitialized) {
      context.read<CameraBloc>().add(const TakePictureRequested());
    }
  }

  void _toggleCamera() {
    _isRearCameraSelected = !_isRearCameraSelected;
    context.read<CameraBloc>().add(
          SwitchCameraRequested(
            useRearCamera: _isRearCameraSelected,
          ),
        );
  }

  void _setFlashMode(FlashMode mode) {
    setState(() {
      _flashMode = mode;
    });
    context.read<CameraBloc>().add(SetFlashModeRequested(flashMode: mode));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('camera.title'.tr()),
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme:
            IconThemeData(color: Theme.of(context).colorScheme.onSurface),
      ),
      body: BlocConsumer<CameraBloc, CameraState>(
        listener: (context, state) {
          if (state is CameraInitialized) {
            setState(() {
              _controller = state.controller;
              _isCameraInitialized = true;
              _minZoomLevel = state.minZoomLevel;
              _maxZoomLevel = state.maxZoomLevel;
              _currentZoomLevel = state.currentZoomLevel;
              _flashMode = state.flashMode;
            });
          } else if (state is PictureTaken) {
            Navigator.of(context).pushNamed(
              RouteConstants.scanResult,
              arguments: {'imagePath': state.imagePath},
            );
          } else if (state is CameraError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage)),
            );
          }
        },
        builder: (context, state) {
          if (state is CameraInitializing || !_isCameraInitialized) {
            return const Center(child: CircularProgressIndicator());
          }

          return SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Camera Preview
                      Positioned.fill(
                        child: _controller != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: CameraPreview(_controller!),
                              )
                            : Container(
                                color: Colors.black,
                                child: const Center(
                                  child: Text(
                                    '相机未初始化',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                      ),

                      // Zoom Slider
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black38,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Text(
                                  '${_currentZoomLevel.toStringAsFixed(1)}x',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                SizedBox(
                                  height: 150,
                                  width: 30,
                                  child: RotatedBox(
                                    quarterTurns: 3,
                                    child: Slider(
                                      value: _currentZoomLevel,
                                      min: _minZoomLevel,
                                      max: _maxZoomLevel,
                                      activeColor: Colors.white,
                                      inactiveColor: Colors.white30,
                                      onChanged: (value) {
                                        setState(() {
                                          _currentZoomLevel = value;
                                        });
                                        context.read<CameraBloc>().add(
                                              SetZoomLevelRequested(
                                                zoomLevel: value,
                                              ),
                                            );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Flash mode selection
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black38,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    _flashMode == FlashMode.off
                                        ? Icons.flash_off
                                        : _flashMode == FlashMode.auto
                                            ? Icons.flash_auto
                                            : Icons.flash_on,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    if (_flashMode == FlashMode.off) {
                                      _setFlashMode(FlashMode.auto);
                                    } else if (_flashMode == FlashMode.auto) {
                                      _setFlashMode(FlashMode.always);
                                    } else {
                                      _setFlashMode(FlashMode.off);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Camera controls
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          color: Colors.black45,
                          height: 100,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // Gallery button
                              IconButton(
                                icon: const Icon(
                                  Icons.photo_library,
                                  color: Colors.white,
                                  size: 28,
                                ),
                                onPressed: () {
                                  context.read<CameraBloc>().add(
                                        const PickFromGalleryRequested(),
                                      );
                                },
                              ),
                              // Capture button
                              GestureDetector(
                                onTap: _takePicture,
                                child: Container(
                                  height: 70,
                                  width: 70,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 3,
                                    ),
                                    color: Colors.white24,
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.camera_alt,
                                      size: 40,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              // Camera flip button
                              IconButton(
                                icon: const Icon(
                                  Icons.flip_camera_ios,
                                  color: Colors.white,
                                  size: 28,
                                ),
                                onPressed: _toggleCamera,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
