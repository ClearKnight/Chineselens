import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:chinese_lens/firebase_options.dart';
import 'package:chinese_lens/config/constants.dart';
import 'package:chinese_lens/config/router.dart';
import 'package:chinese_lens/features/auth/presentation/bloc/bloc.dart';

// BLoC观察者，用于调试
class SimpleBlocObserver extends BlocObserver {
  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    debugPrint('${bloc.runtimeType} $transition');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    debugPrint('${bloc.runtimeType} $error $stackTrace');
    super.onError(bloc, error, stackTrace);
  }
}

// 初始化服务
Future<void> initServices() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化本地化
  await EasyLocalization.ensureInitialized();

  // 初始化Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

void main() async {
  try {
    // 初始化服务
    await initServices();

    // 设置BLoC观察者
    Bloc.observer = SimpleBlocObserver();

    runApp(
      EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('zh')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        child: const MyApp(),
      ),
    );
  } catch (e) {
    debugPrint('Application initialization error: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc()..add(const AppStarted()),
        ),
      ],
      child: MaterialApp(
        title: 'Chinese Lens',
        debugShowCheckedModeBanner: false,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(AppTheme.primaryColor),
            brightness: Brightness.light,
            secondary: const Color(AppTheme.secondaryColor),
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: true,
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(AppTheme.primaryColor),
            brightness: Brightness.dark,
            secondary: const Color(AppTheme.secondaryColor),
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: true,
          ),
        ),
        themeMode: ThemeMode.system,
        onGenerateRoute: AppRouter.generateRoute,
        initialRoute: RouteConstants.login,
      ),
    );
  }
}
