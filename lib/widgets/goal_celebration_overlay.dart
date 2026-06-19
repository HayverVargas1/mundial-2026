import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import '../../providers/app_providers.dart';

class GoalCelebrationOverlay extends ConsumerWidget {
  final Widget child;

  const GoalCelebrationOverlay({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCelebrating = ref.watch(goalCelebrationProvider);

    return Stack(
      children: [
        child,
        if (isCelebrating)
          Positioned.fill(
            child: IgnorePointer(
              child: Center(
                child: Lottie.network(
                  'https://assets9.lottiefiles.com/packages/lf20_u4yrau.json',
                  repeat: false,
                  fit: BoxFit.cover,
                  onLoaded: (composition) {
                    Future.delayed(composition.duration, () {
                      ref.read(goalCelebrationProvider.notifier).state = false;
                    });
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }
}
