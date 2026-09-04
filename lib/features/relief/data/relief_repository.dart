// FILE: lib/features/relief/data/relief_repository.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/reset_content.dart';
import 'reset_catalog.dart';

/// Legacy asynchronous adapter for the dormant Relief player.
///
/// It delegates to ResetCatalog and contains no independent content list.
final reliefRepositoryProvider = FutureProvider<List<ResetContent>>((ref) async {
  return ref.watch(resetCatalogProvider).getAll();
});

final singleReliefContentProvider =
    FutureProvider.family<ResetContent, String>((ref, id) async {
      final content = ref.watch(resetCatalogProvider).getById(id);
      if (content == null) {
        throw StateError('Unknown Reset content ID: $id');
      }
      return content;
    });
