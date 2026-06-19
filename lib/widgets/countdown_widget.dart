import 'package:flutter/material.dart';
import 'dart:async';
import '../core/constants/app_colors.dart';

class CountdownWidget extends StatefulWidget {
  final DateTime targetDate;

  const CountdownWidget({Key? key, required this.targetDate}) : super(key: key);

  @override
  State<CountdownWidget> createState() => _CountdownWidgetState();
}

class _CountdownWidgetState extends State<CountdownWidget> {
  Timer? _timer;
  Duration _diff = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateDiff();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateDiff();
    });
  }

  void _updateDiff() {
    if (mounted) {
      setState(() {
        _diff = widget.targetDate.difference(DateTime.now());
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_diff.isNegative || _diff.inSeconds <= 0) {
      return const Text(
        'POR EMPEZAR',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.secondary,
          fontSize: 16,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
        ),
      );
    }

    final days = _diff.inDays;
    final hours = _diff.inHours.remainder(24);
    final minutes = _diff.inMinutes.remainder(60);
    final seconds = _diff.inSeconds.remainder(60);

    if (days > 0) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'EN $days DÍAS',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.secondary, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.0),
          ),
          Text(
            '${hours}h ${minutes}m ${seconds}s',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.secondary, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.5),
          ),
        ],
      );
    } else {
      String display = 'EN ';
      if (hours > 0) display += '${hours}h ';
      display += '${minutes}m ${seconds}s';
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'EN BREVE',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.secondary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0),
          ),
          Text(
            display.replaceFirst('EN ', ''),
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.secondary, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.5),
          ),
        ],
      );
    }
  }
}
