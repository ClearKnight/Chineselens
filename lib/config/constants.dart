class AppConstants {
  // API URLs
  static const String baseUrl = 'https://api.example.com';
  static const String visionApiUrl =
      'https://vision.googleapis.com/v1/images:annotate';

  // Firebase Collections
  static const String usersCollection = 'user';
  static const String cardsCollection = 'card';
  static const String categoriesCollection = 'category';

  // Storage Paths
  static const String userImagesPath = 'user_images';
  static const String cardImagesPath = 'card_images';

  // Default Values
  static const int maxImageSize = 1024; // 1024kb
  static const int maxCardsPerQuery = 20;
  static const int defaultRecentItems = 5;

  // Shared Preferences Keys
  static const String prefUserId = 'user_id';
  static const String prefAppLanguage = 'app_language';
  static const String prefAppTheme = 'app_theme';
  static const String prefFirstTime = 'first_time';
}

class AppTheme {
  // Primary Colors
  static const int primaryColor = 0xFF4E7BFE;
  static const int secondaryColor = 0xFF7A5AF8;
  static const int accentColor = 0xFF00C6AE;

  // Text Colors
  static const int textPrimary = 0xFF212121;
  static const int textSecondary = 0xFF757575;

  // Background Colors
  static const int backgroundColor = 0xFFF5F5F5;
  static const int surfaceColor = 0xFFFFFFFF;

  // Status Colors
  static const int successColor = 0xFF43A047;
  static const int errorColor = 0xFFE53935;
  static const int warningColor = 0xFFFFB300;
  static const int infoColor = 0xFF2196F3;
}

class ApiConstants {
  static const int timeoutDuration = 30000; // 30 seconds
  static const int maxRetryAttempts = 3;
  static const int retryDelay = 1000; // 1 second
  static const String visionApiUrl =
      'https://vision.googleapis.com/v1/images:annotate';
  static const int maxResults = 10;
  static const String languageCode = 'zh-Hans';
  static const String visionApiBaseUrl = 'https://vision.googleapis.com/v1';
  static const String visionApiTextDetection = '/images:annotate';
}

class UiConstants {
  // Padding
  static const double paddingXs = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXl = 32.0;
  static const double paddingXxl = 48.0;

  // Border Radius
  static const double cardRadius = 12.0;
  static const double buttonRadius = 8.0;
  static const double inputRadius = 12.0;
  static const double dialogRadius = 16.0;

  // Elevation
  static const double elevationNone = 0.0;
  static const double elevationXs = 1.0;
  static const double elevationS = 2.0;
  static const double elevationM = 4.0;
  static const double elevationL = 8.0;
  static const double elevationXl = 16.0;

  // Animation
  static const int animationDurationShort = 150;
  static const int animationDurationMedium = 300;
  static const int animationDurationLong = 500;

  // Font Sizes
  static const double fontSizeXs = 12.0;
  static const double fontSizeS = 14.0;
  static const double fontSizeM = 16.0;
  static const double fontSizeL = 18.0;
  static const double fontSizeXl = 20.0;
  static const double fontSizeXxl = 24.0;
  static const double fontSizeXxxl = 32.0;

  // Image related
  static const double imageThumbnailSize = 80.0;
  static const double imagePreviewHeight = 200.0;
}

class RouteConstants {
  static const String home = '/home';
  static const String login = '/login';
  static const String register = '/register';
  static const String onboarding = '/onboarding';
  static const String camera = '/camera';
  static const String scanResult = '/scan_result';
  static const String wordDetails = '/word_details';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String learningCards = '/learning_cards';
}

class SharedPrefsKeys {
  static const String userId = 'user_id';
  static const String userEmail = 'user_email';
  static const String userName = 'user_name';
  static const String isLoggedIn = 'is_logged_in';
  static const String apiKey = 'api_key';
  static const String themeMode = 'theme_mode';
  static const String locale = 'locale';
}

class FirebaseCollections {
  static const String users = 'users';
  static const String scanHistory = 'scan_history';
  static const String savedWords = 'saved_words';
  static const String userProgress = 'user_progress';
}
