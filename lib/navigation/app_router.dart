import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';

import '../core/localization/app_localizations.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/habits/habits_screen.dart';
import '../screens/finance/finance_screen.dart';
import '../screens/finance/savings_screen.dart';
import '../screens/finance/debts_screen.dart';
import '../screens/workouts/workouts_screen.dart';
import '../screens/planner/planner_screen.dart';
import '../core/services/update_service.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DashboardScreen(),
            ),
          ),
          GoRoute(
            path: '/habits',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HabitsScreen(),
            ),
          ),
          GoRoute(
            path: '/finance',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: FinanceScreen(),
            ),
          ),
          GoRoute(
            path: '/workouts',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: WorkoutsScreen(),
            ),
          ),
          GoRoute(
            path: '/planner',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: PlannerScreen(),
            ),
          ),
          GoRoute(
            path: '/savings',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SavingsScreen(),
            ),
          ),
          GoRoute(
            path: '/debts',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DebtsScreen(),
            ),
          ),
        ],
      ),
    ],
  );
});

class MainShell extends ConsumerStatefulWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _currentIndex = 0;

  static const _routes = ['/', '/habits', '/finance', '/workouts', '/planner'];

  void _onTap(int index) {
    setState(() => _currentIndex = index);
    context.go(_routes[index]);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final location = GoRouterState.of(context).uri.toString();
    for (int i = 0; i < _routes.length; i++) {
      if (location == _routes[i] || (_routes[i] != '/' && location.startsWith(_routes[i]))) {
        if (_currentIndex != i) {
          setState(() => _currentIndex = i);
        }
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
            onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
          ),
        ],
      ),
      drawer: _buildDrawer(context, l10n, theme),
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTap,
        type: BottomNavigationBarType.fixed,
        iconSize: 22,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: l10n.dashboard,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.check_circle_outline),
            activeIcon: const Icon(Icons.check_circle),
            label: l10n.habits,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.account_balance_wallet_outlined),
            activeIcon: const Icon(Icons.account_balance_wallet),
            label: l10n.finance,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.fitness_center_outlined),
            activeIcon: const Icon(Icons.fitness_center),
            label: l10n.workouts,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.calendar_view_week_outlined),
            activeIcon: const Icon(Icons.calendar_view_week),
            label: l10n.planner,
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, AppLocalizations l10n, ThemeData theme) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.appTitle,
                    style: theme.textTheme.headlineMedium,
                  ),
                  const Gap(4),
                  Text(
                    l10n.settings,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.savings),
              title: Text(l10n.savings),
              onTap: () {
                Navigator.pop(context);
                context.go('/savings');
              },
            ),
            ListTile(
              leading: const Icon(Icons.credit_card),
              title: Text(l10n.debts),
              onTap: () {
                Navigator.pop(context);
                context.go('/debts');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.system_update),
              title: Text(l10n.checkUpdate),
              onTap: () async {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.checking)),
                );
                try {
                  final info = await UpdateService.checkForUpdate();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  if (info.hasUpdate) {
                    _showUpdateDialog(context, info, l10n);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${l10n.noUpdate} (${info.currentVersion})')),
                    );
                  }
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${l10n.networkError} (${e.runtimeType})')),
                  );
                }
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(l10n.language),
              trailing: Text(
                ref.read(localeProvider).languageCode == 'ru' ? 'RU' : 'EN',
                style: theme.textTheme.labelLarge,
              ),
              onTap: () {
                ref.read(localeProvider.notifier).toggleLocale();
              },
            ),
            ListTile(
              leading: Icon(
                Theme.of(context).brightness == Brightness.dark
                    ? Icons.light_mode
                    : Icons.dark_mode,
              ),
              title: Text(
                Theme.of(context).brightness == Brightness.dark
                    ? l10n.lightTheme
                    : l10n.darkTheme,
              ),
              onTap: () {
                ref.read(themeModeProvider.notifier).toggle();
              },
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'v1.1.4',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUpdateDialog(BuildContext context, UpdateInfo info, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.updateAvailable),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${l10n.currentVersion}: 1.0.0'),
              const Gap(4),
              Text('${l10n.newVersion}: ${info.latestVersion}'),
              if (info.releaseNotes.isNotEmpty) ...[
                const Gap(12),
                Text(l10n.changelog, style: const TextStyle(fontWeight: FontWeight.w600)),
                const Gap(4),
                Text(info.releaseNotes),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
          if (info.downloadUrl.isNotEmpty)
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                UpdateService.openDownload(info.downloadUrl);
              },
              child: Text(l10n.download),
            ),
        ],
      ),
    );
  }
}
