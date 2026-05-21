import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../widgets/eid_background.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: EidBackground(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: EidColors.cream.withValues(alpha: 0.95),
                  shape: BoxShape.circle,
                  border: Border.all(color: EidColors.gold, width: 3),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: EidColors.darkGreen.withValues(alpha: 0.3),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.brightness_2,
                  size: 56,
                  color: EidColors.gold,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'جمعتنا',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: EidColors.cream,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'لمَّتنا في عيد الأضحى',
                style: TextStyle(
                  fontSize: 16,
                  color: EidColors.gold.withValues(alpha: 0.95),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 56),
              const SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(
                  color: EidColors.gold,
                  strokeWidth: 3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
