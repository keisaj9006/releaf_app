import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:releaf_app/features/home/whats_new_content.dart';
import 'package:releaf_app/features/home/whats_new_store.dart';

class _MemoryStore implements WhatsNewStore {
  _MemoryStore({
    this.lastAcknowledgedRelease,
    this.writeSucceeds = true,
    this.throwOnRead = false,
  });
  String? lastAcknowledgedRelease;
  bool writeSucceeds;
  bool throwOnRead;
  int writes = 0;

  @override
  String? readLastAcknowledgedRelease() {
    if (throwOnRead) throw StateError('unavailable');
    return lastAcknowledgedRelease;
  }

  @override
  Future<bool> writeLastAcknowledgedRelease(String releaseId) async {
    writes++;
    if (writeSucceeds) lastAcknowledgedRelease = releaseId;
    return writeSucceeds;
  }
}

void main() {
  test('empty preferences show the current release once', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final store = SharedPreferencesWhatsNewStore(preferences);
    final controller = WhatsNewController(store);
    expect(controller.state.show, isTrue);
    expect(controller.state.releaseId, WhatsNewContent.current.releaseId);
    await controller.acknowledge();
    expect(controller.state.show, isFalse);
    expect(
      store.readLastAcknowledgedRelease(),
      WhatsNewContent.current.releaseId,
    );
    expect(WhatsNewController(store).state.show, isFalse);
  });

  test('an older acknowledgement does not hide the current release', () {
    final store = _MemoryStore(lastAcknowledgedRelease: 'releaf-older');
    expect(WhatsNewController(store).state.show, isTrue);
  });

  test('repeated acknowledgement writes once', () async {
    final store = _MemoryStore();
    final controller = WhatsNewController(store);
    await controller.acknowledge();
    await controller.acknowledge();
    expect(store.writes, 1);
  });

  test('failed write still enters Home in this session', () async {
    final store = _MemoryStore(writeSucceeds: false);
    final controller = WhatsNewController(store);
    await controller.acknowledge();
    expect(controller.state.show, isFalse);
    expect(WhatsNewController(store).state.show, isTrue);
  });

  test('failed read falls back to Home', () {
    final store = _MemoryStore(throwOnRead: true);
    expect(WhatsNewController(store).state.show, isFalse);
  });
}
