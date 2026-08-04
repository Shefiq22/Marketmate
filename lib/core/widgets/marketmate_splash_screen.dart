import 'package:flutter/material.dart';

class MarketmateSplashScreen extends StatelessWidget {
  const MarketmateSplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF041A14),
      body: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/mm_mmicon.png',
              width: 76,
              height: 76,
              cacheWidth: 76,
              cacheHeight: 76,
            ),
            const SizedBox(width: 8),
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
                children: [
                  TextSpan(text: 'Market', style: TextStyle(color: Colors.white)),
                  TextSpan(
                    text: 'Mate',
                    style: TextStyle(color: Color(0xFFF79C28)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
