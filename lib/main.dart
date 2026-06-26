import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';
import 'package:share_lib/share_lib_auth.dart';
import 'package:tabata_timer/l10n/app_localizations.dart';

import 'config/kakao_config.dart';
import 'data/routine_repository.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'services/ad_settings.dart';
import 'services/content_settings.dart';
import 'services/locale_settings.dart';
import 'services/routine_api_client.dart';
import 'services/routine_content_localizer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init error: $e');
  }

  if (KakaoConfig.isConfigured) {
    KakaoSdk.init(
      nativeAppKey: KakaoConfig.nativeAppKey,
      javaScriptAppKey: KakaoConfig.javaScriptAppKey,
    );
  } else {
    debugPrint('Kakao SDK skipped: app keys not configured');
  }

  final contentSettings = await ContentSettings.load();
  final contentLocalizer = RoutineContentLocalizer(
    contentSettings: contentSettings,
  );
  final apiClient = RoutineApiClient(contentLocalizer: contentLocalizer);
  final repository = await RoutineRepository.create(apiClient: apiClient);
  await AdSettings.initialize();
  runApp(TabataApp(
    repository: repository,
    apiClient: apiClient,
  ));
}

class TabataApp extends StatelessWidget {
  const TabataApp({
    super.key,
    required this.repository,
    required this.apiClient,
  });

  final RoutineRepository repository;
  final RoutineApiClient apiClient;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        AuthLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      localeResolutionCallback: (locale, supportedLocales) {
        return LocaleSettings.resolveSystemLocale(
          systemLocale: locale,
          supportedLocales: supportedLocales.toList(),
        );
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE53935),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: true),
      ),
      builder: (context, child) {
        if (child == null) return const SizedBox.shrink();
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.0),
          ),
          child: child,
        );
      },
      home: HomeScreen(
        repository: repository,
        apiClient: apiClient,
      ),
    );
  }
}
