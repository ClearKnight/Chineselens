import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:chinese_lens/features/auth/data/repositories/firebase_auth_repository.dart';
import 'package:chinese_lens/features/auth/domain/repositories/auth_repository.dart';
import 'package:chinese_lens/features/auth/presentation/bloc/bloc.dart';
import 'package:chinese_lens/core/network/vision_api_client.dart';

/// 提供全局依赖
class AppProviders {
  // Firebase
  static final firebaseAuth = FirebaseAuth.instance;
  static final firestore = FirebaseFirestore.instance;
  static final googleSignIn = GoogleSignIn();

  // Repositories
  static AuthRepository authRepository() => FirebaseAuthRepository(
        firebaseAuth: firebaseAuth,
        firestore: firestore,
        googleSignIn: googleSignIn,
      );

  // API Clients
  static GoogleVisionApiClient visionApiClient(String apiKey) =>
      GoogleVisionApiClient(apiKey: apiKey);

  // Blocs
  static AuthBloc authBloc() => AuthBloc(
        firebaseAuth: firebaseAuth,
        firestore: firestore,
        googleSignIn: googleSignIn,
      );

  /// 获取所有全局BlocProvider
  static List<BlocProvider> getBlocProviders() {
    return [
      BlocProvider<AuthBloc>(
        create: (context) => authBloc()..add(const AppStarted()),
      ),
    ];
  }
}

/// 初始化所有需要预先加载的服务
Future<void> initServices() async {
  // TODO: 添加需要预先初始化的服务
}
