import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

/// 处理图片上传和存储的仓库
class StorageRepository {
  final FirebaseStorage _storage;
  final Uuid _uuid;

  /// 创建StorageRepository实例
  /// [storage] 可选的FirebaseStorage实例，默认使用Firebase.instance
  StorageRepository({
    FirebaseStorage? storage,
    Uuid? uuid,
  })  : _storage = storage ?? FirebaseStorage.instance,
        _uuid = uuid ?? const Uuid();

  /// 上传图片到Firebase Storage
  /// [imageFile] 要上传的图片文件
  /// [userId] 用户ID，用于组织存储路径
  /// 返回图片的下载URL
  Future<String> uploadImage(File imageFile, String userId) async {
    try {
      // 生成唯一文件名
      final String fileExtension = path.extension(imageFile.path);
      final String fileName = '${_uuid.v4()}$fileExtension';

      // 定义存储路径，按用户ID分组
      final String storagePath = 'images/$userId/$fileName';

      // 创建存储引用
      final Reference ref = _storage.ref().child(storagePath);

      // 设置元数据
      final SettableMetadata metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'userId': userId,
          'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
        },
      );

      // 上传文件
      final UploadTask uploadTask = ref.putFile(imageFile, metadata);

      // 监听上传进度
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        // 计算上传进度，将来可用于更新UI显示进度条
        // ignore: unused_local_variable
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        // TODO: 通过BLoC发送上传进度更新
      });

      // 等待上传完成并获取下载URL
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw StorageException('上传图片失败: $e');
    }
  }

  /// 删除Firebase Storage中的图片
  /// [imageUrl] 要删除的图片URL
  Future<void> deleteImage(String imageUrl) async {
    try {
      // 从URL中提取引用路径
      final Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      throw StorageException('删除图片失败: $e');
    }
  }
}

/// 存储异常类
class StorageException implements Exception {
  final String message;

  StorageException(this.message);

  @override
  String toString() => message;
}
