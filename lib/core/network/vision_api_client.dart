import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:chinese_lens/config/constants.dart';
import 'package:chinese_lens/core/utils/logger.dart';

class GoogleVisionApiClient {
  late final Dio _dio;
  final String _apiKey;

  GoogleVisionApiClient({required String apiKey}) : _apiKey = apiKey {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.visionApiUrl,
        connectTimeout:
            const Duration(milliseconds: ApiConstants.timeoutDuration),
        receiveTimeout:
            const Duration(milliseconds: ApiConstants.timeoutDuration),
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          AppLogger.d('VISION API REQUEST => URL: ${options.uri}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          AppLogger.d('VISION API RESPONSE[${response.statusCode}]');
          return handler.next(response);
        },
        onError: (DioException error, handler) {
          AppLogger.e(
            'VISION API ERROR[${error.response?.statusCode}] => MESSAGE: ${error.message}',
          );
          return handler.next(error);
        },
      ),
    );
  }

  Future<RecognitionResult> recognizeImage(File imageFile) async {
    try {
      // Convert image to base64
      final List<int> imageBytes = await imageFile.readAsBytes();
      final String base64Image = base64Encode(imageBytes);

      // Prepare request payload
      final Map<String, dynamic> requestData = {
        'requests': [
          {
            'image': {
              'content': base64Image,
            },
            'features': [
              {
                'type': 'LABEL_DETECTION',
                'maxResults': 10,
              },
              {
                'type': 'TEXT_DETECTION',
                'maxResults': 5,
              },
              {
                'type': 'OBJECT_LOCALIZATION',
                'maxResults': 5,
              },
            ],
          },
        ],
      };

      // Make API call
      final Response response = await _dio.post(
        '?key=$_apiKey',
        data: requestData,
      );

      // Process response
      return RecognitionResult.fromResponse(response.data);
    } on DioException catch (e) {
      AppLogger.e('Vision API Error', e);
      throw ApiException(
        message: 'Failed to recognize image: ${e.message}',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      AppLogger.e('Vision API Unexpected Error', e);
      throw ApiException(
        message: 'Unexpected error during image recognition: $e',
      );
    }
  }
}

class RecognitionResult {
  final List<RecognizedLabel> labels;
  final List<RecognizedObject> objects;
  final List<RecognizedText> texts;

  RecognitionResult({
    required this.labels,
    required this.objects,
    required this.texts,
  });

  factory RecognitionResult.fromResponse(Map<String, dynamic> data) {
    final responses = data['responses'] as List<dynamic>;

    if (responses.isEmpty) {
      return RecognitionResult(
        labels: [],
        objects: [],
        texts: [],
      );
    }

    final responseData = responses[0] as Map<String, dynamic>;

    // Extract labels
    final List<RecognizedLabel> labels = [];
    if (responseData.containsKey('labelAnnotations')) {
      final labelAnnotations =
          responseData['labelAnnotations'] as List<dynamic>;
      labels.addAll(
        labelAnnotations
            .map((label) => RecognizedLabel.fromJson(label))
            .toList(),
      );
    }

    // Extract objects
    final List<RecognizedObject> objects = [];
    if (responseData.containsKey('localizedObjectAnnotations')) {
      final objectAnnotations =
          responseData['localizedObjectAnnotations'] as List<dynamic>;
      objects.addAll(
        objectAnnotations
            .map((object) => RecognizedObject.fromJson(object))
            .toList(),
      );
    }

    // Extract texts
    final List<RecognizedText> texts = [];
    if (responseData.containsKey('textAnnotations') &&
        (responseData['textAnnotations'] as List<dynamic>).isNotEmpty) {
      final textAnnotations = responseData['textAnnotations'] as List<dynamic>;
      texts.addAll(
        textAnnotations
            .skip(1)
            .map((text) => RecognizedText.fromJson(text))
            .toList(),
      );
    }

    return RecognitionResult(
      labels: labels,
      objects: objects,
      texts: texts,
    );
  }
}

class RecognizedLabel {
  final String description;
  final double score;

  RecognizedLabel({
    required this.description,
    required this.score,
  });

  factory RecognizedLabel.fromJson(Map<String, dynamic> json) {
    return RecognizedLabel(
      description: json['description'] as String,
      score: json['score'].toDouble(),
    );
  }
}

class RecognizedObject {
  final String name;
  final double score;

  RecognizedObject({
    required this.name,
    required this.score,
  });

  factory RecognizedObject.fromJson(Map<String, dynamic> json) {
    return RecognizedObject(
      name: json['name'] as String,
      score: json['score'].toDouble(),
    );
  }
}

class RecognizedText {
  final String text;
  final double confidence;

  RecognizedText({
    required this.text,
    this.confidence = 0.0,
  });

  factory RecognizedText.fromJson(Map<String, dynamic> json) {
    return RecognizedText(
      text: json['description'] as String,
      confidence:
          json.containsKey('confidence') ? json['confidence'].toDouble() : 0.0,
    );
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException({
    required this.message,
    this.statusCode,
  });

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}
