import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabata_timer/data/routine_repository.dart';
import 'package:tabata_timer/models/profile_summary.dart';
import 'package:tabata_timer/models/routine.dart';
import 'package:tabata_timer/services/routine_api_client.dart';

class _FakeApiClient extends RoutineApiClient {
  _FakeApiClient({
    List<ProfileSummary>? officialSummaries,
    List<ProfileSummary>? sharedSummaries,
    List<ProfileSummary>? summaries,
    required Map<String, Routine> profiles,
  })  : _officialSummaries = officialSummaries ?? summaries ?? const [],
        _sharedSummaries = sharedSummaries ?? const [],
        _profiles = profiles,
        super();

  final List<ProfileSummary> _officialSummaries;
  final List<ProfileSummary> _sharedSummaries;
  final Map<String, Routine> _profiles;
  var fetchProfileCallCount = 0;

  @override
  Future<List<ProfileSummary>> fetchProfileSummaries({
    bool official = true,
  }) async =>
      official ? _officialSummaries : _sharedSummaries;

  @override
  Future<List<String>> fetchProfileIds() async =>
      _officialSummaries.map((summary) => summary.id).toList();

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

ProfileSummary _summary(
  String id, {
  String title = 'Test',
  int count = 1,
  String ownerId = ProfileSummary.officialCatalogOwner,
}) {
  return ProfileSummary(
    id: id,
    title: title,
    description: '',
    exerciseCount: count,
    ownerId: ownerId,
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
    expect(repository.myRoutines, isEmpty);
    expect(repository.isCatalogId('tabata-basic'), isTrue);
    expect(repository.isLocalRoutine('tabata-basic'), isFalse);
    expect(repository.officialCatalogSummaries.single.id, 'tabata-basic');
  });

  test('forkCatalogProfile saves a new local routine with new id', () async {
    final serverRoutine = _routine('tabata-basic', title: 'Server');
    final api = _FakeApiClient(
      summaries: [_summary('tabata-basic', title: 'Server')],
      profiles: {'tabata-basic': serverRoutine},
    );
    final repository = await RoutineRepository.create(apiClient: api);
    await repository.refreshRemoteProfiles();

    final forked = await repository.forkCatalogProfile('tabata-basic');

    expect(api.fetchProfileCallCount, 1);
    expect(forked.title, 'Server');
    expect(forked.id, isNot('tabata-basic'));
    expect(repository.isLocalRoutine(forked.id), isTrue);
    expect(repository.isCatalogId('tabata-basic'), isTrue);
    expect(repository.myRoutines.map((r) => r.id), [forked.id]);
  });

  test('forking same catalog twice creates two local routines', () async {
    final api = _FakeApiClient(
      summaries: [_summary('tabata-basic', title: 'Server')],
      profiles: {'tabata-basic': _routine('tabata-basic', title: 'Server')},
    );
    final repository = await RoutineRepository.create(apiClient: api);
    await repository.refreshRemoteProfiles();

    final first = await repository.forkCatalogProfile('tabata-basic');
    final second = await repository.forkCatalogProfile('tabata-basic');

    expect(first.id, isNot(second.id));
    expect(repository.myRoutines, hasLength(2));
  });

  test('legacy migration reconciles fork metadata for catalog ids', () async {
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
    expect(repository.myRoutines.single.id, 'tabata-basic');
  });

  test('delete removes local routine only', () async {
    final api = _FakeApiClient(
      summaries: [_summary('tabata-basic', title: 'Server')],
      profiles: {'tabata-basic': _routine('tabata-basic', title: 'Server')},
    );
    final repository = await RoutineRepository.create(apiClient: api);
    await repository.refreshRemoteProfiles();

    final forked = await repository.forkCatalogProfile('tabata-basic');
    await repository.delete(forked.id);

    expect(repository.myRoutines, isEmpty);
    expect(repository.isCatalogId('tabata-basic'), isTrue);
  });

  test('myRoutines respects saved list order', () async {
    SharedPreferences.setMockInitialValues({
      'local_routine_records_v1':
          '[{"routine":{"schemaVersion":1,"id":"a","title":"A","description":"","exercises":[]}},'
          '{"routine":{"schemaVersion":1,"id":"b","title":"B","description":"","exercises":[]}}]',
      'routine_list_order_v1': ['b', 'a'],
    });

    final api = _FakeApiClient(summaries: [], profiles: {});
    final repository = await RoutineRepository.create(apiClient: api);

    expect(repository.myRoutines.map((routine) => routine.id), ['b', 'a']);
  });

  test('shared catalog excludes admin owner profiles', () async {
    final api = _FakeApiClient(
      officialSummaries: [
        _summary('official-a', title: 'Official'),
      ],
      sharedSummaries: [
        _summary('shared-a', title: 'Shared', ownerId: 'user-1'),
        _summary('official-a', title: 'Leaked', ownerId: 'admin'),
      ],
      profiles: {
        'official-a': _routine('official-a', title: 'Official'),
        'shared-a': _routine('shared-a', title: 'Shared'),
      },
    );
    final repository = await RoutineRepository.create(apiClient: api);

    await repository.refreshRemoteProfiles();

    expect(repository.officialCatalogSummaries.map((s) => s.id), ['official-a']);
    expect(repository.sharedCatalogSummaries.map((s) => s.id), ['shared-a']);
    expect(repository.myRoutines, isEmpty);
  });

  test('copyForServerUpload always uses a distinct id from the local routine',
      () async {
    final api = _FakeApiClient(summaries: [], profiles: {});
    final repository = await RoutineRepository.create(apiClient: api);
    final local = _routine('local-a', title: 'Mine');

    final firstUpload = repository.copyForServerUpload(local);
    final secondUpload = repository.copyForServerUpload(local);

    expect(firstUpload.id, isNot(local.id));
    expect(secondUpload.id, isNot(local.id));
    expect(firstUpload.id, isNot(secondUpload.id));
    expect(firstUpload.title, local.title);
  });

  test('copyForServerUpload reuses server profile id when updating', () async {
    final api = _FakeApiClient(summaries: [], profiles: {});
    final repository = await RoutineRepository.create(apiClient: api);
    final local = _routine('local-a', title: 'Mine');

    final updated = repository.copyForServerUpload(
      local,
      existingServerProfileId: 'server-copy-1',
    );

    expect(updated.id, 'server-copy-1');
    expect(updated.id, isNot(local.id));
  });

  test('setUploadedServerProfileId links local routine to server copy', () async {
    final api = _FakeApiClient(summaries: [], profiles: {});
    final repository = await RoutineRepository.create(apiClient: api);
    await repository.upsert(_routine('local-a', title: 'Mine'));

    await repository.setUploadedServerProfileId(
      localRoutineId: 'local-a',
      serverProfileId: 'server-b',
    );

    expect(repository.uploadedServerProfileIdFor('local-a'), 'server-b');
    expect(repository.findById('local-a')!.id, 'local-a');
  });

  test('saveListOrder persists custom order', () async {
    final api = _FakeApiClient(summaries: [], profiles: {});
    final repository = await RoutineRepository.create(apiClient: api);

    await repository.saveListOrder(['c', 'a', 'b']);

    expect(repository.myRoutines, isEmpty);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList('routine_list_order_v1'), ['c', 'a', 'b']);
  });
}
