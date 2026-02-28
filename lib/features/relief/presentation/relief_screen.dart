// FILE: lib/features/relief/presentation/relief_screen.dart
// ACTION: UPDATE (Całkowite nadpisanie)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/relief_repository.dart';
import '../domain/models/content_item.dart';

class ReliefScreen extends ConsumerWidget {
  const ReliefScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reliefState = ref.watch(reliefRepositoryProvider);

    return Scaffold(
      backgroundColor: Colors.white, // Dostosuj do AppTheme
      appBar: AppBar(
        title: const Text('Ulga i Regulacja', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: reliefState.when(
        data: (items) => _buildContent(context, items),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text('Wystąpił błąd: ${err.toString()}', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(reliefRepositoryProvider),
                child: const Text('Spróbuj ponownie'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<ContentItem> items) {
    final emergencies = items.where((i) => i.type == ContentType.emergency).toList();
    final regulars = items.where((i) => i.type != ContentType.emergency).toList();

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(reliefRepositoryProvider),
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Sekcja Emergency (Safety by design)
          if (emergencies.isNotEmpty) ...[
            const Text(
              'Potrzebujesz szybkiej pomocy?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.redAccent),
            ),
            const SizedBox(height: 12),
            ...emergencies.map((item) => _buildEmergencyCard(context, item)),
            const SizedBox(height: 32),
          ],

          // Sekcja Biblioteki
          const Text(
            'Biblioteka Ćwiczeń',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: regulars.length,
            itemBuilder: (context, index) {
              return _buildContentCard(context, regulars[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyCard(BuildContext context, ContentItem item) {
    return Semantics(
      button: true,
      label: 'Szybki ratunek: ${item.title}',
      child: InkWell(
        onTap: () => _navigateToPlayer(context, item),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.1),
            border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(Icons.health_and_safety, color: Colors.red, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(item.oneLiner, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.red, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentCard(BuildContext context, ContentItem item) {
    final isPremium = item.accessTier == AccessTier.premium;

    return Semantics(
      button: true,
      label: 'Ćwiczenie: ${item.title}',
      child: InkWell(
        onTap: () => _navigateToPlayer(context, item),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(_getIconForType(item.type), color: Colors.teal),
                  if (isPremium) const Icon(Icons.lock, color: Colors.amber, size: 16),
                ],
              ),
              const Spacer(),
              Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('${item.durationSec ~/ 60} min', style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForType(ContentType type) {
    switch (type) {
      case ContentType.breath: return Icons.air;
      case ContentType.sound: return Icons.headphones;
      case ContentType.noBreath: return Icons.self_improvement;
      default: return Icons.spa;
    }
  }

  void _navigateToPlayer(BuildContext context, ContentItem item) {
    // UWAGA: Tu w przyszłości dodasz logikę sprawdzania Paywalla.
    // if (item.accessTier == AccessTier.premium && !userHasPremium) { showPaywall(); return; }

    context.push('/relief/play/${item.id}');
  }
}