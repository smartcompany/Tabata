import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tabata_timer/l10n/app_localizations.dart';

import 'data/routine_repository.dart';
import 'screens/home_screen.dart';
import 'services/locale_settings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final repository = await RoutineRepository.create();
  final localeSettings = await LocaleSettings.load();
  runApp(TabataApp(
    repository: repository,
    localeSettings: localeSettings,
  ));
}

class TabataApp extends StatefulWidget {
  const TabataApp({
    super.key,
    required this.repository,
    required this.localeSettings,
  });

  final RoutineRepository repository;
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
      home: HomeScreen(
        repository: widget.repository,
        localeSettings: widget.localeSettings,
        onLocaleChanged: _onLocaleChanged,
      ),
    );
  }
}
