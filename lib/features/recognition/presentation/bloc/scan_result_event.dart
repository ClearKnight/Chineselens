import 'package:equatable/equatable.dart';

abstract class ScanResultEvent extends Equatable {
  const ScanResultEvent();

  @override
  List<Object?> get props => [];
}

class ProcessImageRequested extends ScanResultEvent {
  final String imagePath;
  final String userId;

  const ProcessImageRequested({
    required this.imagePath,
    required this.userId,
  });

  @override
  List<Object?> get props => [imagePath, userId];
}

class SaveToLearningCardRequested extends ScanResultEvent {
  final String imageUrl;
  final String userId;
  final String text;

  const SaveToLearningCardRequested({
    required this.imageUrl,
    required this.userId,
    required this.text,
  });

  @override
  List<Object?> get props => [imageUrl, userId, text];
}

class RetakePhotoRequested extends ScanResultEvent {
  const RetakePhotoRequested();
}
