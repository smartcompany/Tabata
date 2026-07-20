import '../data/routine_repository.dart';
import 'app_analytics_service.dart';
import 'app_settings_service.dart';

/// Seeds a short recommended catalog routine for activation flows.
abstract final class OnboardingRoutineSeeder {
  static const _preferredIds = [
    'first-try',
    'tabata-basic',
    'upper-body-warmup',
  ];

  /// Forks the first available onboarding recommended routine.
  /// Returns the local routine id, or null if nothing could be seeded.
  static Future<String?> seedFirstRecommended(
    RoutineRepository repository, {
    String analyticsSource = 'onboarding',
  }) async {
    try {
      if (repository.officialCatalogSummaries.isEmpty) {
        await repository.refreshRemoteProfiles();
      }

      final remoteIds =
          await AppSettingsService.onboardingRecommendedRoutineIds();
      final orderedIds = <String>[
        ..._preferredIds,
        ...remoteIds,
        ...repository.officialCatalogSummaries.map((s) => s.id),
      ];
      final seen = <String>{};

      for (final id in orderedIds) {
        if (!seen.add(id)) continue;
        final summary = repository.catalogSummaryFor(id);
        if (summary == null || !summary.isOfficialCatalog) continue;

        if (repository.hasDownloadedCatalog(id)) {
          final existing = repository.myRoutinesForkedFromCatalog(id);
          if (existing.isNotEmpty) return existing.first.id;
        }

        final forked = await repository.forkCatalogProfile(id);
        await AppAnalyticsService.logRoutineDownload(
          source: analyticsSource,
          count: 1,
        );
        return forked.id;
      }
    } catch (_) {}
    return null;
  }
}
