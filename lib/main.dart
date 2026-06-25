import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tabata_timer/l10n/app_localizations.dart';

import 'data/routine_repository.dart';
import 'screens/home_screen.dart';
import 'services/admin_session.dart';
import 'services/locale_settings.dart';
import 'services/routine_api_client.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final apiClient = RoutineApiClient();
  final repository = await RoutineRepository.create(apiClient: apiClient);
  final adminSession = await AdminSession.create();
  final localeSettings = await LocaleSettings.load();
  runApp(TabataApp(
    repository: repository,
    apiClient: apiClient,
    adminSession: adminSession,
    localeSettings: localeSettings,
  ));
}

class TabataApp extends StatefulWidget {
  const TabataApp({
    super.key,
    required this.repository,
    required this.apiClient,
    required this.adminSession,
    required this.localeSettings,
  });

  final RoutineRepository repository;
  final RoutineApiClient apiClient;
  final AdminSession adminSession;
  final LocaleSettings localeSettings;

  @override
  State<TabataApp> createState() => _TabataAppState();
}

class _TabataAppState extends State<TabataApp> {
  Locale? _localeOverride;

  @override
  void initState() {
    super.initState();
    _localeOverride = widget.localeSettings.locale;
    LocaleSettings.addListener(_onLocaleChanged);
  }

  @override
  void dispose() {
    LocaleSettings.removeListener(_onLocaleChanged);
    super.dispose();
  }

  void _onLocaleChanged() {
    setState(() => _localeOverride = widget.localeSettings.locale);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      locale: _localeOverride,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      localeResolutionCallback: (locale, supportedLocales) {
        return LocaleSettings.resolveLocale(
          override: _localeOverride,
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
        localeSettings: widget.localeSettings,
        onLocaleChanged: _onLocaleChanged,
      ),
    );
  }
}
