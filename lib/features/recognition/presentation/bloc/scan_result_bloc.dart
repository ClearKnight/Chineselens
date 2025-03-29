import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:chinese_lens/features/recognition/data/repositories/recognition_repository.dart';
import 'package:chinese_lens/features/recognition/data/repositories/storage_repository.dart';
import 'package:chinese_lens/features/recognition/data/api/vision_api_client.dart';
import 'package:chinese_lens/features/recognition/domain/entities/recognition_result.dart';
import 'package:chinese_lens/features/recognition/presentation/bloc/scan_result_event.dart';
import 'package:chinese_lens/features/recognition/presentation/bloc/scan_result_state.dart';

/// 处理扫描结果页面的业务逻辑
/// 管理图片处理、上传、文字识别等过程
class ScanResultBloc extends Bloc<ScanResultEvent, ScanResultState> {
  final RecognitionRepository _recognitionRepository;
  final StorageRepository _storageRepository;

  ScanResultBloc({
    required RecognitionRepository recognitionRepository,
    required StorageRepository storageRepository,
  })  : _recognitionRepository = recognitionRepository,
        _storageRepository = storageRepository,
        super(const ScanResultLoading()) {
    on<ProcessImageRequested>(_onProcessImageRequested);
    on<SaveToLearningCardRequested>(_onSaveToLearningCardRequested);
    on<RetakePhotoRequested>(_onRetakePhotoRequested);
  }

  /// 处理图像识别请求
  /// [event] 处理图像事件
  /// [emit] 状态发射器
  Future<void> _onProcessImageRequested(
    ProcessImageRequested event,
    Emitter<ScanResultState> emit,
  ) async {
    try {
      emit(const ScanResultLoading());

      // 验证本地图片文件
      final File imageFile = File(event.imagePath);
      if (!await imageFile.exists()) {
        emit(ScanResultError(
          errorMessage: '图片文件不存在: ${event.imagePath}',
          imagePath: event.imagePath,
        ));
        return;
      }

      // 上传图片到Firebase Storage
      final String imageUrl = await _storageRepository.uploadImage(
        imageFile,
        event.userId,
      );

      // 识别图像中的文字
      final RecognitionResult recognitionResult =
          await _recognitionRepository.recognizeText(event.imagePath);

      // 发射成功状态
      emit(ScanResultSuccess(
        recognitionResult: recognitionResult,
        imageUrl: imageUrl,
        localImagePath: event.imagePath,
      ));
    } on StorageException catch (e) {
      emit(ScanResultError(
        errorMessage: '上传图片失败: ${e.message}',
        imagePath: event.imagePath,
      ));
    } on VisionApiException catch (e) {
      emit(ScanResultError(
        errorMessage: '文字识别失败: ${e.message}',
        imagePath: event.imagePath,
      ));
    } catch (e) {
      emit(ScanResultError(
        errorMessage: '处理图像失败: $e',
        imagePath: event.imagePath,
      ));
    }
  }

  /// 处理保存到学习卡片请求
  /// [event] 保存学习卡片事件
  /// [emit] 状态发射器
  Future<void> _onSaveToLearningCardRequested(
    SaveToLearningCardRequested event,
    Emitter<ScanResultState> emit,
  ) async {
    try {
      emit(const SavingToLearningCard());

      // TODO: 实现保存到学习卡片的逻辑
      // 这里应该调用学习卡片的Repository创建新卡片

      // 模拟创建卡片
      await Future.delayed(const Duration(seconds: 1));
      const String cardId = 'card_123'; // 测试ID，后续实现真实保存功能后替换

      emit(const SavedToLearningCard(cardId: cardId));
    } catch (e) {
      emit(SaveToLearningCardError(errorMessage: '保存学习卡片失败: $e'));
    }
  }

  /// 处理重新拍照请求
  /// [event] 重新拍照事件
  /// [emit] 状态发射器
  void _onRetakePhotoRequested(
    RetakePhotoRequested event,
    Emitter<ScanResultState> emit,
  ) {
    // 不需要执行任何特殊逻辑，由页面处理返回相机
  }
}
