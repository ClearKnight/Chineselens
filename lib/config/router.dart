import 'package:flutter/material.dart';
import 'package:chinese_lens/config/constants.dart';
import 'package:chinese_lens/features/auth/presentation/pages/login_page.dart';
import 'package:chinese_lens/features/auth/presentation/pages/register_page.dart';
import 'package:chinese_lens/features/home/presentation/pages/home_page.dart';
import 'package:chinese_lens/features/camera/presentation/pages/camera_page.dart';
import 'package:chinese_lens/features/recognition/presentation/pages/scan_result_page.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteConstants.login:
        return MaterialPageRoute(builder: (_) => const LoginPage());

      case RouteConstants.register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());

      case RouteConstants.home:
        return MaterialPageRoute(builder: (_) => const HomePage());

      case RouteConstants.camera:
        return MaterialPageRoute(builder: (_) => const CameraPage());

      case RouteConstants.scanResult:
        final args = settings.arguments as Map<String, dynamic>?;
        final imagePath = args?['imagePath'] as String?;

        if (imagePath == null) {
          return MaterialPageRoute(
            builder: (_) => Scaffold(
              appBar: AppBar(title: const Text('错误')),
              body: const Center(child: Text('未提供图像路径')),
            ),
          );
        }

        return MaterialPageRoute(
          builder: (_) => ScanResultPage(imagePath: imagePath),
        );

      case RouteConstants.wordDetails:
        final args = settings.arguments as Map<String, dynamic>?;
        // 暂时使用占位页
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('词汇详情')),
            body: Center(
              child: Text('词汇: ${args?['word'] ?? '无数据'}'),
            ),
          ),
        );

      case RouteConstants.profile:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('个人页面')),
          ),
        );

      case RouteConstants.settings:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('设置')),
            body: const Center(child: Text('设置页面')),
          ),
        );

      case RouteConstants.onboarding:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('引导页')),
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('找不到路由: ${settings.name}'),
            ),
          ),
        );
    }
  }
}
