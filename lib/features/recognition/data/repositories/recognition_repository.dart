import 'dart:io';
import 'package:chinese_lens/features/recognition/data/api/vision_api_client.dart';
import 'package:chinese_lens/features/recognition/domain/entities/recognition_result.dart';

class RecognitionRepository {
  final VisionApiClient _apiClient;

  RecognitionRepository({VisionApiClient? apiClient})
      : _apiClient = apiClient ?? VisionApiClient();

  /// 识别图像中的文字
  Future<RecognitionResult> recognizeText(String imagePath) async {
    try {
      // 检查文件是否存在
      final File imageFile = File(imagePath);
      if (!await imageFile.exists()) {
        throw Exception('图像文件不存在: $imagePath');
      }

      // 调用API客户端进行识别
      return await _apiClient.detectText(imagePath);
    } catch (e) {
      throw Exception('文字识别失败: $e');
    }
  }
}
