import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';
import 'package:share_lib/share_lib_auth.dart';
import 'package:tabata_timer/l10n/app_localizations.dart';

import 'config/kakao_config.dart';
import 'data/routine_repository.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'services/admin_session.dart';
import 'services/ad_settings.dart';
import 'services/content_settings.dart';
import 'services/locale_settings.dart';
import 'services/routine_api_client.dart';
import 'services/routine_content_localizer.dart';
import 'services/routine_share_api.dart';
import 'services/shared_routine_link_coordinator.dart';
import 'services/share_link_log.dart';

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

  if (!kIsWeb) {
    await MobileAds.instance.initialize();
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
  final adminSession = await AdminSession.create();
  await AdSettings.initialize();

  final navigatorKey = GlobalKey<NavigatorState>();
  final linkCoordinator = SharedRoutineLinkCoordinator(
    navigatorKey: navigatorKey,
    repository: repository,
    shareApi: RoutineShareApi(),
  );

  runApp(TabataApp(
    repository: repository,
    apiClient: apiClient,
    adminSession: adminSession,
    navigatorKey: navigatorKey,
    linkCoordinator: linkCoordinator,
  ));
}

class TabataApp extends StatefulWidget {
  const TabataApp({
    super.key,
    required this.repository,
    required this.apiClient,
    required this.adminSession,
    required this.navigatorKey,
    required this.linkCoordinator,
  });

  final RoutineRepository repository;
  final RoutineApiClient apiClient;
  final AdminSession adminSession;
  final GlobalKey<NavigatorState> navigatorKey;
  final SharedRoutineLinkCoordinator linkCoordinator;

  @override
  State<TabataApp> createState() => _TabataAppState();
}

class _TabataAppState extends State<TabataApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      shareLinkLog('TabataApp first frame — starting link coordinator');
      if (!kIsWeb) {
        unawaited(widget.linkCoordinator.start());
      }
    });
  }

  @override
  void dispose() {
    widget.linkCoordinator.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: widget.navigatorKey,
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
        repository: widget.repository,
        apiClient: widget.apiClient,
        adminSession: widget.adminSession,
        linkCoordinator: widget.linkCoordinator,
      ),
    );
  }
}
