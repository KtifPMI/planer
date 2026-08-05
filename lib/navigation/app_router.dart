import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../core/localization/app_localizations.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/nav_providers.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/habits/habits_screen.dart';
import '../screens/finance/finance_screen.dart';
import '../screens/finance/savings_screen.dart';
import '../screens/finance/debts_screen.dart';
import '../screens/workouts/workouts_screen.dart';
import '../screens/planner/planner_screen.dart';
import '../screens/nutrition/nutrition_screen.dart';
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
            path: '/nutrition',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: NutritionScreen(),
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
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) {
      if (mounted) setState(() => _appVersion = info.version);
    });
  }

  void _onTap(int index) {
    final tabs = ref.read(visibleTabKeysProvider);
    final all = ref.read(allNavTabsProvider);
    final tabKey = tabs[index];
    final tab = all.firstWhere((t) => t.key == tabKey);
    setState(() => _currentIndex = index);
    context.go(tab.route);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final location = GoRouterState.of(context).uri.toString();
    final tabs = ref.read(visibleTabKeysProvider);
    final all = ref.read(allNavTabsProvider);
    for (int i = 0; i < tabs.length; i++) {
      final tab = all.firstWhere((t) => t.key == tabs[i]);
      if (location == tab.route || (tab.route != '/' && location.startsWith(tab.route))) {
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
    final visibleKeys = ref.watch(visibleTabKeysProvider);
    final allTabs = ref.watch(allNavTabsProvider);

    final visibleTabs = allTabs.where((t) => visibleKeys.contains(t.key)).toList();

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
      drawer: _buildDrawer(context, l10n, theme, allTabs, visibleKeys),
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex < visibleTabs.length ? _currentIndex : 0,
        onTap: _onTap,
        type: BottomNavigationBarType.fixed,
        iconSize: 22,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        items: visibleTabs.map((tab) => BottomNavigationBarItem(
          icon: Icon(tab.icon),
          activeIcon: Icon(tab.activeIcon),
          label: tab.label(l10n),
        )).toList(),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, AppLocalizations l10n, ThemeData theme,
      List<NavTab> allTabs, List<String> visibleKeys) {
    final disabledTabs = allTabs.where((t) => !visibleKeys.contains(t.key)).toList();

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
                  Text(l10n.appTitle, style: theme.textTheme.headlineMedium),
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

            // Disabled tabs (quick access from drawer)
            if (disabledTabs.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  l10n.navigation,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ),
              ...disabledTabs.map((tab) => ListTile(
                leading: Icon(tab.icon, size: 22),
                title: Text(tab.label(l10n)),
                onTap: () {
                  Navigator.pop(context);
                  context.go(tab.route);
                },
              )),
              const Divider(),
            ],

            // Customize tabs
            ListTile(
              leading: const Icon(Icons.tune),
              title: Text(l10n.customizeTabs),
              onTap: () {
                Navigator.pop(context);
                _showCustomizeTabsDialog(context, l10n, theme, allTabs, visibleKeys);
              },
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
              onTap: () {
                Navigator.pop(context);
                UpdateService.checkAndShow(context);
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
                'v$_appVersion',
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

  void _showCustomizeTabsDialog(BuildContext context, AppLocalizations l10n, ThemeData theme,
      List<NavTab> allTabs, List<String> visibleKeys) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.8,
          expand: false,
          builder: (ctx, scrollCtrl) => Consumer(
            builder: (ctx, ref, _) {
              final keys = ref.watch(visibleTabKeysProvider);
              return Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: theme.dividerColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const Gap(16),
                  Text(l10n.customizeTabs, style: theme.textTheme.titleLarge),
                  const Gap(4),
                  Text(l10n.customizeTabsHint, style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  )),
                  const Gap(8),
                  Expanded(
                    child: ListView(
                      controller: scrollCtrl,
                      children: allTabs.map((tab) => SwitchListTile(
                        value: keys.contains(tab.key),
                        onChanged: (_) {
                          toggleTabKey(ref, tab.key);
                          setModalState(() {});
                        },
                        title: Text(tab.label(l10n)),
                        secondary: Icon(tab.icon),
                      )).toList(),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
