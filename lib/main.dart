import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/constants/app_strings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/app_providers.dart';
import 'theme/app_theme.dart';
import 'screens/matches/matches_screen.dart';
import 'screens/groups/groups_screen.dart';
import 'screens/bracket/bracket_screen.dart';
import 'screens/live/live_screen.dart';
import 'screens/ranking/ranking_screen.dart';

import 'widgets/bottom_nav.dart';
import 'services/notification_service.dart';
import 'services/polling_service.dart';
import 'widgets/goal_celebration_overlay.dart';

import 'services/background_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  await initializeDateFormatting('es', null);
  await initializeService();
  final prefs = await SharedPreferences.getInstance();
  
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const MundialApp(),
    ),
  );
}

class MundialApp extends StatelessWidget {
  const MundialApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const GoalCelebrationOverlay(
        child: MainScreen(),
      ),
    );
  }
}



class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 0;
  static const platform = MethodChannel('com.mundial26.mundial_26/app_retain');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await NotificationService().requestPermission();
      PollingService().start(ProviderScope.containerOf(context), sendNotifications: true, updateWidget: false);
    });
  }

  final List<Widget> _screens = [
    const MatchesScreen(),
    const GroupsScreen(),
    const BracketScreen(),
    const LiveScreen(),
    const RankingScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        
        if (_currentIndex != 0) {
          setState(() {
            _currentIndex = 0;
          });
        } else {
          try {
            await platform.invokeMethod('sendToBackground');
          } catch (e) {
            // ignore
          }
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: BottomNav(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}
