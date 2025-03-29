import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:chinese_lens/config/api_keys.dart';
import 'package:chinese_lens/config/constants.dart';
import 'package:chinese_lens/features/recognition/domain/entities/recognition_result.dart';

/// Google Vision API客户端
/// 处理与Google Cloud Vision API的通信
class VisionApiClient {
  final http.Client _httpClient;

  /// 创建VisionApiClient实例
  /// [httpClient] 可选的http客户端，用于依赖注入和测试
  VisionApiClient({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  /// 使用Vision API识别图像中的文字
  /// [imagePath] 图像文件路径
  /// 返回识别结果实体
  Future<RecognitionResult> detectText(String imagePath) async {
    try {
      // 读取图片文件并转换为base64
      final File imageFile = File(imagePath);
      final List<int> imageBytes = await imageFile.readAsBytes();
      final String base64Image = base64Encode(imageBytes);

      // 构建API请求URL
      final Uri uri = Uri.parse(
          '${ApiConstants.visionApiBaseUrl}${ApiConstants.visionApiTextDetection}?key=${ApiKeys.visionApiKey}');

      // 构建请求体
      final Map<String, dynamic> requestBody = {
        'requests': [
          {
            'image': {
              'content': base64Image,
            },
            'features': [
              {
                'type': 'TEXT_DETECTION',
                'maxResults': ApiConstants.maxResults,
              },
            ],
            'imageContext': {
              'languageHints': ['zh-Hans', 'zh-Hant', 'en'],
            },
          },
        ],
      };

      // 发送请求
      final http.Response response = await _httpClient.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      // 处理响应
      if (response.statusCode == 200) {
        return _parseResponse(response.body);
      } else {
        throw VisionApiException(
          message: '请求失败',
          statusCode: response.statusCode,
          responseBody: response.body,
        );
      }
    } on SocketException {
      throw VisionApiException(
        message: '网络连接失败',
        statusCode: 0,
      );
    } catch (e) {
      if (e is VisionApiException) {
        rethrow;
      }
      throw VisionApiException(
        message: '文本识别失败: $e',
        statusCode: 500,
      );
    }
  }

  /// 解析API响应数据
  /// [responseBody] API响应主体
  /// 返回解析后的RecognitionResult
  RecognitionResult _parseResponse(String responseBody) {
    try {
      final Map<String, dynamic> data = jsonDecode(responseBody);

      // 检查响应中是否包含文本注释
      if (data['responses'] == null ||
          data['responses'].isEmpty ||
          data['responses'][0]['textAnnotations'] == null ||
          data['responses'][0]['textAnnotations'].isEmpty) {
        return RecognitionResult.empty();
      }

      final List<dynamic> textAnnotations =
          data['responses'][0]['textAnnotations'];

      // 第一个文本注释通常是整个图像的文本
      final String fullText = textAnnotations[0]['description'] ?? '';

      // 处理各个单词（从索引1开始，因为索引0是完整文本）
      final List<RecognizedWord> words = [];
      if (textAnnotations.length > 1) {
        for (int i = 1; i < textAnnotations.length; i++) {
          final annotation = textAnnotations[i];
          final String text = annotation['description'] ?? '';

          // 处理边界框坐标
          List<Coordinate> boundingBox = [];
          if (annotation['boundingPoly'] != null &&
              annotation['boundingPoly']['vertices'] != null) {
            final List<dynamic> vertices =
                annotation['boundingPoly']['vertices'];
            for (var vertex in vertices) {
              boundingBox.add(Coordinate(
                x: (vertex['x'] ?? 0).toDouble(),
                y: (vertex['y'] ?? 0).toDouble(),
              ));
            }
          }

          words.add(RecognizedWord(
            text: text,
            boundingBox: boundingBox,
          ));
        }
      }

      return RecognitionResult(
        words: words,
        fullText: fullText,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      throw VisionApiException(
        message: '解析响应失败: $e',
        statusCode: 200,
      );
    }
  }

  /// 释放资源
  void dispose() {
    _httpClient.close();
  }
}

/// Vision API异常类
class VisionApiException implements Exception {
  final String message;
  final int statusCode;
  final String? responseBody;

  VisionApiException({
    required this.message,
    required this.statusCode,
    this.responseBody,
  });

  @override
  String toString() => 'VisionApiException: $message (Status: $statusCode)';
}
