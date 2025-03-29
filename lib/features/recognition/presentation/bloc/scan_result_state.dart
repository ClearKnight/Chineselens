import 'package:equatable/equatable.dart';
import 'package:chinese_lens/features/recognition/domain/entities/recognition_result.dart';

abstract class ScanResultState extends Equatable {
  const ScanResultState();

  @override
  List<Object?> get props => [];
}

class ScanResultInitial extends ScanResultState {
  final String imagePath;

  const ScanResultInitial({required this.imagePath});

  @override
  List<Object?> get props => [imagePath];
}

class ScanResultLoading extends ScanResultState {
  const ScanResultLoading();
}

class ScanResultSuccess extends ScanResultState {
  final RecognitionResult recognitionResult;
  final String imageUrl;
  final String localImagePath;

  const ScanResultSuccess({
    required this.recognitionResult,
    required this.imageUrl,
    required this.localImagePath,
  });

  @override
  List<Object?> get props => [recognitionResult, imageUrl, localImagePath];
}

class ScanResultError extends ScanResultState {
  final String errorMessage;
  final String? imagePath;

  const ScanResultError({
    required this.errorMessage,
    this.imagePath,
  });

  @override
  List<Object?> get props => [errorMessage, imagePath];
}

class SavingToLearningCard extends ScanResultState {
  const SavingToLearningCard();
}

class SavedToLearningCard extends ScanResultState {
  final String cardId;

  const SavedToLearningCard({required this.cardId});

  @override
  List<Object?> get props => [cardId];
}

class SaveToLearningCardError extends ScanResultState {
  final String errorMessage;

  const SaveToLearningCardError({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}
