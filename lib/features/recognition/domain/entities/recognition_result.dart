import 'package:equatable/equatable.dart';

class RecognitionResult extends Equatable {
  final List<RecognizedWord> words;
  final String fullText;
  final DateTime timestamp;

  const RecognitionResult({
    required this.words,
    required this.fullText,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [words, fullText, timestamp];

  factory RecognitionResult.empty() {
    return RecognitionResult(
      words: const [],
      fullText: '',
      timestamp: DateTime.now(),
    );
  }
}

class RecognizedWord extends Equatable {
  final String text;
  final List<Coordinate> boundingBox;

  const RecognizedWord({
    required this.text,
    required this.boundingBox,
  });

  @override
  List<Object?> get props => [text, boundingBox];
}

class Coordinate extends Equatable {
  final double x;
  final double y;

  const Coordinate({
    required this.x,
    required this.y,
  });

  @override
  List<Object?> get props => [x, y];
}
