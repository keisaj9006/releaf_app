// Legacy compatibility adapter.
//
// Active code must use ResetCatalog and ResetContent. This file intentionally
// owns no content data, so it cannot diverge from the canonical catalog.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/reset_content.dart';
import 'reset_catalog.dart';

export '../domain/models/reset_content.dart';
export 'reset_catalog.dart';

typedef ReliefSession = ResetContent;

final audioCatalogProvider = Provider<AudioCatalog>((ref) {
  return AudioCatalog(ref.watch(resetCatalogProvider));
});

class AudioCatalog {
  final ResetCatalog _catalog;

  const AudioCatalog([this._catalog = const ResetCatalog()]);

  static const emergencySessionId = ResetCatalog.emergencySessionId;

  List<ReliefSession> getSessions() => _catalog.getAll();

  List<ReliefSession> getRegularSessions() => _catalog.getRegularContent();

  ReliefSession? getById(String id) => _catalog.getById(id);
}
