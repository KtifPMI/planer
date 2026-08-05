import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/localization/app_localizations.dart';
import '../data/services/storage_service.dart';

class NavTab {
  final String key;
  final String route;
  final IconData icon;
  final IconData activeIcon;

  String label(AppLocalizations l10n) {
    switch (key) {
      case 'dashboard': return l10n.dashboard;
      case 'habits': return l10n.habits;
      case 'finance': return l10n.finance;
      case 'workouts': return l10n.workouts;
      case 'planner': return l10n.planner;
      case 'nutrition': return l10n.nutrition;
      default: return key;
    }
  }

  const NavTab({
    required this.key,
    required this.route,
    required this.icon,
    required this.activeIcon,
  });
}

final allNavTabsProvider = Provider<List<NavTab>>((ref) => const [
  NavTab(key: 'dashboard', route: '/', icon: Icons.home_outlined, activeIcon: Icons.home),
  NavTab(key: 'habits', route: '/habits', icon: Icons.check_circle_outline, activeIcon: Icons.check_circle),
  NavTab(key: 'finance', route: '/finance', icon: Icons.account_balance_wallet_outlined, activeIcon: Icons.account_balance_wallet),
  NavTab(key: 'workouts', route: '/workouts', icon: Icons.fitness_center_outlined, activeIcon: Icons.fitness_center),
  NavTab(key: 'planner', route: '/planner', icon: Icons.calendar_view_week_outlined, activeIcon: Icons.calendar_view_week),
  NavTab(key: 'nutrition', route: '/nutrition', icon: Icons.restaurant_outlined, activeIcon: Icons.restaurant),
]);

final visibleTabKeysProvider = StateProvider<List<String>>((ref) {
  final raw = StorageService.settingsBox.get('visible_tabs');
  if (raw is String) {
    try {
      return List<String>.from(jsonDecode(raw) as List);
    } catch (_) {}
  }
  return ['dashboard', 'habits', 'finance', 'workouts', 'planner', 'nutrition'];
});

void toggleTabKey(WidgetRef ref, String key) {
  final current = ref.read(visibleTabKeysProvider);
  final updated = current.contains(key)
      ? current.length > 1 ? current.where((k) => k != key).toList() : current
      : [...current, key];
  ref.read(visibleTabKeysProvider.notifier).state = updated;
  StorageService.settingsBox.put('visible_tabs', jsonEncode(updated));
}
