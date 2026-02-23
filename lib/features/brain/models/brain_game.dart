// FILE: lib/features/brain/model/brain_game.dart

import 'package:flutter/material.dart';

/// Minimalny model do listy gier na BrainScreen.
/// To jest "meta" gry (id, nazwa, ikonka, opcjonalnie disabled).
class BrainGame {
  final String id;
  final String title;

  /// Ikona w kafelku (prosta, bez assetów na razie)
  final IconData icon;

  /// Jeśli true – kafelek pokazuje "Coming soon" i nie puszcza do hosta.
  final bool disabled;

  const BrainGame({
    required this.id,
    required this.title,
    this.icon = Icons.extension,
    this.disabled = false,
  });
}