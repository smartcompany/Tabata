import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabata_timer/data/routine_repository.dart';
import 'package:tabata_timer/models/profile_summary.dart';
import 'package:tabata_timer/models/routine.dart';
import 'package:tabata_timer/services/routine_api_client.dart';

class _FakeApiClient extends RoutineApiClient {
  _FakeApiClient({
    required List<ProfileSummary> summaries,
    required Map<String, Routine> profiles,
  })  : _summaries = summaries,
        _profiles = profiles,
        super();

  final List<ProfileSummary> _summaries;
  final Map<String, Routine> _profiles;
  var fetchProfileCallCount = 0;

  @override
  Future<List<ProfileSummary>> fetchProfileSummaries({
    bool official = true,
  }) async =>
      _summaries;

  @override
  Future<List<String>> fetchProfileIds() async =>
      _summaries.map((summary) => summary.id).toList();

  @override
  Future<Routine> fetchProfile(String id) async {
    fetchProfileCallCount++;
    final profile = _profiles[id];
    if (profile == null) {
      throw RoutineApiException('missing $id');
    }
    return profile;
  }
}

ProfileSummary _summary(String id, {String title = 'Test', int count = 1}) {
  return ProfileSummary(
    id: id,
    title: title,
    description: '',
    exerciseCount: count,
  );
}

Routine _routine(String id, {String title = 'Test'}) {
  return Routine(
    id: id,
    title: title,
    description: '',
    exercises: const [],
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('refresh fetches catalog without auto-downloading', () async {
    final api = _FakeApiClient(
      summaries: [_summary('tabata-basic', title: 'Server')],
      profiles: {'tabata-basic': _routine('tabata-basic', title: 'Server')},
    );
    final repository = await RoutineRepository.create(apiClient: api);

    await repository.refreshRemoteProfiles();

    expect(api.fetchProfileCallCount, 0);
    expect(repository.loadLocalOnly(), isEmpty);
    expect(repository.isServerProfile('tabata-basic'), isTrue);
    expect(repository.isCatalogStub(repository.loadAll().single), isTrue);
  });

  test('downloadCatalogProfile saves locally', () async {
    final serverRoutine = _routine('tabata-basic', title: 'Server');
    final api = _FakeApiClient(
      summaries: [_summary('tabata-basic', title: 'Server')],
      profiles: {'tabata-basic': serverRoutine},
    );
    final repository = await RoutineRepository.create(apiClient: api);
    await repository.refreshRemoteProfiles();

    final downloaded = await repository.downloadCatalogProfile('tabata-basic');

    expect(api.fetchProfileCallCount, 1);
    expect(downloaded.title, 'Server');
    expect(repository.isDownloadedLocally('tabata-basic'), isTrue);
    expect(repository.isCatalogStub(downloaded), isFalse);
  });

  test('undownloaded catalog routines appear after downloaded ones', () async {
    SharedPreferences.setMockInitialValues({
      'local_routines_v1':
          '[{"schemaVersion":1,"id":"local-a","title":"Local","description":"","exercises":[]}]',
    });

    final api = _FakeApiClient(
      summaries: [
        _summary('tabata-basic', title: 'Server'),
        _summary('tabata-core', title: 'Core'),
      ],
      profiles: {
        'tabata-basic': _routine('tabata-basic', title: 'Server'),
        'tabata-core': _routine('tabata-core', title: 'Core'),
      },
    );
    final repository = await RoutineRepository.create(apiClient: api);
    await repository.refreshRemoteProfiles();

    final routines = repository.loadAll();
    expect(routines.map((routine) => routine.id), [
      'local-a',
      'tabata-basic',
      'tabata-core',
    ]);
    expect(repository.isCatalogStub(routines[1]), isTrue);
    expect(repository.isCatalogStub(routines[2]), isTrue);
  });

  test('skips download when profile id already exists locally', () async {
    SharedPreferences.setMockInitialValues({
      'local_routines_v1':
          '[{"schemaVersion":1,"id":"tabata-basic","title":"Custom","description":"","exercises":[]}]',
    });

    final api = _FakeApiClient(
      summaries: [_summary('tabata-basic', title: 'Server')],
      profiles: {'tabata-basic': _routine('tabata-basic', title: 'Server')},
    );
    final repository = await RoutineRepository.create(apiClient: api);

    await repository.refreshRemoteProfiles();

    expect(api.fetchProfileCallCount, 0);
    expect(repository.findById('tabata-basic')!.title, 'Custom');
    expect(repository.isCatalogStub(repository.loadAll().single), isFalse);
  });

  test('delete removes local copy and catalog stub reappears', () async {
    SharedPreferences.setMockInitialValues({
      'local_routines_v1':
          '[{"schemaVersion":1,"id":"tabata-basic","title":"Custom","description":"","exercises":[]}]',
    });

    final api = _FakeApiClient(
      summaries: [_summary('tabata-basic', title: 'Server')],
      profiles: {'tabata-basic': _routine('tabata-basic', title: 'Server')},
    );
    final repository = await RoutineRepository.create(apiClient: api);
    await repository.refreshRemoteProfiles();

    await repository.delete('tabata-basic');

    expect(repository.loadLocalOnly(), isEmpty);
    expect(repository.isCatalogStub(repository.loadAll().single), isTrue);
  });

  test('rollbackToServer replaces local copy with server data', () async {
    SharedPreferences.setMockInitialValues({
      'local_routines_v1':
          '[{"schemaVersion":1,"id":"tabata-basic","title":"Custom","description":"","exercises":[]}]',
    });

    final serverRoutine = _routine('tabata-basic', title: 'Server default');
    final api = _FakeApiClient(
      summaries: [_summary('tabata-basic', title: 'Server')],
      profiles: {'tabata-basic': serverRoutine},
    );
    final repository = await RoutineRepository.create(apiClient: api);
    await repository.refreshRemoteProfiles();

    final restored = await repository.rollbackToServer('tabata-basic');

    expect(restored.title, 'Server default');
    expect(repository.findById('tabata-basic')!.title, 'Server default');
    expect(api.fetchProfileCallCount, 1);
  });

  test('loadAll respects saved list order for downloaded routines', () async {
    SharedPreferences.setMockInitialValues({
      'local_routines_v1':
          '[{"schemaVersion":1,"id":"a","title":"A","description":"","exercises":[]},'
          '{"schemaVersion":1,"id":"b","title":"B","description":"","exercises":[]}]',
      'routine_list_order_v1': ['b', 'a'],
    });

    final api = _FakeApiClient(
      summaries: [
        _summary('a', title: 'A'),
        _summary('b', title: 'B'),
      ],
      profiles: {
        'a': _routine('a', title: 'A'),
        'b': _routine('b', title: 'B'),
      },
    );
    final repository = await RoutineRepository.create(apiClient: api);
    await repository.refreshRemoteProfiles();

    final routines = repository.loadAll();
    expect(routines.map((routine) => routine.id), ['b', 'a']);
  });

  test('saveListOrder persists custom order', () async {
    final api = _FakeApiClient(summaries: [], profiles: {});
    final repository = await RoutineRepository.create(apiClient: api);

    await repository.saveListOrder(['c', 'a', 'b']);

    expect(repository.loadAll(), isEmpty);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList('routine_list_order_v1'), ['c', 'a', 'b']);
  });
}
