import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:chinese_lens/config/constants.dart';
import 'package:chinese_lens/features/auth/presentation/bloc/bloc.dart';
import 'package:chinese_lens/features/recognition/data/repositories/recognition_repository.dart';
import 'package:chinese_lens/features/recognition/data/repositories/storage_repository.dart';
import 'package:chinese_lens/features/recognition/domain/entities/recognition_result.dart';
import 'package:chinese_lens/features/recognition/presentation/bloc/bloc.dart';

class ScanResultPage extends StatelessWidget {
  final String imagePath;

  const ScanResultPage({
    Key? key,
    required this.imagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ScanResultBloc(
        recognitionRepository: RecognitionRepository(),
        storageRepository: StorageRepository(),
      )..add(
          ProcessImageRequested(
            imagePath: imagePath,
            userId: context.read<AuthBloc>().state.user?.id ?? 'anonymous',
          ),
        ),
      child: const ScanResultView(),
    );
  }
}

class ScanResultView extends StatelessWidget {
  const ScanResultView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('recognition.scanResult'.tr()),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: () {
              context.read<ScanResultBloc>().add(const RetakePhotoRequested());
              Navigator.of(context).pushReplacementNamed(RouteConstants.camera);
            },
          ),
        ],
      ),
      body: BlocConsumer<ScanResultBloc, ScanResultState>(
        listener: (context, state) {
          if (state is SavedToLearningCard) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('recognition.savedToCard'.tr()),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
            );
          } else if (state is SaveToLearningCardError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ScanResultLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ScanResultSuccess) {
            return _buildResultContent(context, state);
          } else if (state is ScanResultError) {
            return _buildErrorContent(context, state);
          } else if (state is SavingToLearningCard) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('保存中...'),
                ],
              ),
            );
          } else if (state is ScanResultInitial) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('准备处理图片...'),
                ],
              ),
            );
          } else {
            return const Center(child: Text('未知状态'));
          }
        },
      ),
    );
  }

  Widget _buildResultContent(BuildContext context, ScanResultSuccess state) {
    final recognitionResult = state.recognitionResult;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(UiConstants.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 图片预览
          ClipRRect(
            borderRadius: BorderRadius.circular(UiConstants.cardRadius),
            child: Image.file(
              File(state.localImagePath),
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: UiConstants.paddingL),

          // 识别结果标题
          Text(
            'recognition.detectedText'.tr(),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: UiConstants.paddingM),

          // 完整识别文本
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(UiConstants.paddingM),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(UiConstants.cardRadius),
            ),
            child: Text(
              recognitionResult.fullText.isEmpty
                  ? 'recognition.noTextDetected'.tr()
                  : recognitionResult.fullText,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          const SizedBox(height: UiConstants.paddingL),

          // 识别到的单词列表
          if (recognitionResult.words.isNotEmpty) ...[
            Text(
              'recognition.words'.tr(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: UiConstants.paddingM),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recognitionResult.words.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final word = recognitionResult.words[index];
                return _buildWordItem(context, word, index);
              },
            ),
          ],

          const SizedBox(height: UiConstants.paddingXl),

          // 保存按钮
          Center(
            child: ElevatedButton.icon(
              onPressed: recognitionResult.fullText.isNotEmpty
                  ? () {
                      context.read<ScanResultBloc>().add(
                            SaveToLearningCardRequested(
                              imageUrl: state.imageUrl,
                              userId: context.read<AuthBloc>().state.user?.id ??
                                  'anonymous',
                              text: recognitionResult.fullText,
                            ),
                          );
                    }
                  : null,
              icon: const Icon(Icons.save),
              label: Text('recognition.saveToCard'.tr()),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: UiConstants.paddingL,
                  vertical: UiConstants.paddingM,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWordItem(BuildContext context, RecognizedWord word, int index) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Text('${index + 1}'),
      ),
      title: Text(
        word.text,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      trailing: IconButton(
        icon: const Icon(Icons.volume_up),
        onPressed: () {
          // TODO: 实现TTS朗读功能
        },
      ),
      onTap: () {
        // TODO: 显示单词详情或学习材料
      },
    );
  }

  Widget _buildErrorContent(BuildContext context, ScanResultError state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 60,
          ),
          const SizedBox(height: 16),
          Text(
            state.errorMessage,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('common.back'.tr()),
          ),
        ],
      ),
    );
  }
}
