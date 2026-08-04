import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Bare centered Lottie animation — embed inside existing layouts
/// (home screen, dashboard, etc.) without any Scaffold wrapper.
class SandyLoader extends StatelessWidget {
  const SandyLoader({super.key, this.size});

  final double? size;

  static const String _assetPath = 'assets/animations/Sandy Loading.json';

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Lottie.asset(
        _assetPath,
        width: size ?? 200,
        height: size ?? 200,
        fit: BoxFit.contain,
        backgroundLoading: true,
      ),
    );
  }
}

/// Full-screen version wrapped in a Scaffold for app-boot / page-level
/// transitions.  Automatically adapts background to dark / light mode.
class SandyFullScreenLoader extends StatelessWidget {
  const SandyFullScreenLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: const SandyLoader(),
    );
  }
}
