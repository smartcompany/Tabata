import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabata_timer/data/routine_repository.dart';
import 'package:tabata_timer/models/routine.dart';
import 'package:tabata_timer/services/routine_api_client.dart';

class _FakeApiClient extends RoutineApiClient {
  _FakeApiClient({
    required List<String> ids,
    required Map<String, Routine> profiles,
  })  : _ids = ids,
        _profiles = profiles,
        super();

  final List<String> _ids;
  final Map<String, Routine> _profiles;
  var fetchProfileCallCount = 0;

  @override
  Future<List<String>> fetchProfileIds() async => _ids;

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

  test('downloads server profiles missing locally and saves them', () async {
    final serverRoutine = _routine('tabata-basic', title: 'Server');
    final api = _FakeApiClient(
      ids: ['tabata-basic'],
      profiles: {'tabata-basic': serverRoutine},
    );
    final repository = await RoutineRepository.create(apiClient: api);

    await repository.refreshRemoteProfiles();

    expect(api.fetchProfileCallCount, 1);
    final saved = repository.loadLocalOnly();
    expect(saved.length, 1);
    expect(saved.single.id, 'tabata-basic');
    expect(saved.single.title, 'Server');
    expect(repository.isServerProfile('tabata-basic'), isTrue);
  });

  test('skips download when profile id already exists locally', () async {
  final localRoutine = _routine('tabata-basic', title: 'Custom');
    SharedPreferences.setMockInitialValues({
      'local_routines_v1':
          '[{"schemaVersion":1,"id":"tabata-basic","title":"Custom","description":"","exercises":[]}]',
    });

    final api = _FakeApiClient(
      ids: ['tabata-basic'],
      profiles: {'tabata-basic': _routine('tabata-basic', title: 'Server')},
    );
    final repository = await RoutineRepository.create(apiClient: api);

    await repository.refreshRemoteProfiles();

    expect(api.fetchProfileCallCount, 0);
    expect(repository.findById('tabata-basic')!.title, 'Custom');
  });

  test('rollbackToServer replaces local copy with server data', () async {
    final localRoutine = _routine('tabata-basic', title: 'Custom');
    SharedPreferences.setMockInitialValues({
      'local_routines_v1':
          '[{"schemaVersion":1,"id":"tabata-basic","title":"Custom","description":"","exercises":[]}]',
    });

    final serverRoutine = _routine('tabata-basic', title: 'Server default');
    final api = _FakeApiClient(
      ids: ['tabata-basic'],
      profiles: {'tabata-basic': serverRoutine},
    );
    final repository = await RoutineRepository.create(apiClient: api);
    await repository.refreshRemoteProfiles();

    final restored = await repository.rollbackToServer('tabata-basic');

    expect(restored.title, 'Server default');
    expect(repository.findById('tabata-basic')!.title, 'Server default');
    expect(api.fetchProfileCallCount, 1);
  });

  test('loadAll respects saved list order', () async {
    SharedPreferences.setMockInitialValues({
      'local_routines_v1':
          '[{"schemaVersion":1,"id":"a","title":"A","description":"","exercises":[]},'
          '{"schemaVersion":1,"id":"b","title":"B","description":"","exercises":[]}]',
      'routine_list_order_v1': ['b', 'a'],
    });

    final api = _FakeApiClient(
      ids: ['a', 'b'],
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
    final api = _FakeApiClient(ids: [], profiles: {});
    final repository = await RoutineRepository.create(apiClient: api);

    await repository.saveListOrder(['c', 'a', 'b']);

    expect(repository.loadAll(), isEmpty);
    final order = SharedPreferences.getInstance();
    final prefs = await order;
    expect(prefs.getStringList('routine_list_order_v1'), ['c', 'a', 'b']);
  });
}
