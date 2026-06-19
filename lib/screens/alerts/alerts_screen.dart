import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_colors.dart';
import '../../services/notification_service.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({Key? key}) : super(key: key);

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  bool matchStart15Min = false;
  bool matchStarted = false;
  bool goal = false;
  bool halfTime = false;
  bool finalResult = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      matchStart15Min = prefs.getBool('matchStart15Min') ?? false;
      matchStarted = prefs.getBool('matchStarted') ?? false;
      goal = prefs.getBool('goal') ?? false;
      halfTime = prefs.getBool('halfTime') ?? false;
      finalResult = prefs.getBool('finalResult') ?? false;
    });
  }

  Future<void> _savePreference(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  void _handleToggle(String typeName, String prefKey, bool value, ValueChanged<bool> setter) async {
    if (value) {
      final granted = await NotificationService().requestPermission();
      if (granted) {
        setter(value);
        _savePreference(prefKey, value);
        NotificationService().showMatchNotification(
          title: '¡Alerta Activada!', 
          body: 'Recibirás notificaciones de $typeName en este dispositivo.',
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Permiso de notificaciones denegado. Para recibir alertas, actívalas en los ajustes de tu dispositivo.')),
          );
        }
      }
    } else {
      setter(value);
      _savePreference(prefKey, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.alertsTitle, style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAlertItem(
            AppStrings.alertMatchStart,
            AppStrings.alertMatchStartSub,
            matchStart15Min,
            (v) => _handleToggle('15 minutos antes', 'matchStart15Min', v, (val) => setState(() => matchStart15Min = val)),
          ),
          _buildAlertItem(
            AppStrings.alertMatchStarted,
            AppStrings.alertMatchStartedSub,
            matchStarted,
            (v) => _handleToggle('Inicio del partido', 'matchStarted', v, (val) => setState(() => matchStarted = val)),
          ),
          _buildAlertItem(
            AppStrings.alertGoal,
            AppStrings.alertGoalSub,
            goal,
            (v) => _handleToggle('Goles', 'goal', v, (val) => setState(() => goal = val)),
          ),
          _buildAlertItem(
            AppStrings.alertHalfTime,
            AppStrings.alertHalfTimeSub,
            halfTime,
            (v) => _handleToggle('Medio tiempo', 'halfTime', v, (val) => setState(() => halfTime = val)),
          ),
          _buildAlertItem(
            AppStrings.alertFinalResult,
            AppStrings.alertFinalResultSub,
            finalResult,
            (v) => _handleToggle('Resultado final', 'finalResult', v, (val) => setState(() => finalResult = val)),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertItem(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: SwitchListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.background,
        activeTrackColor: AppColors.secondary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}
