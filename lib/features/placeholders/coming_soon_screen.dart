import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../widgets/eid_app_bar.dart';

class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({
    super.key,
    required this.title,
    required this.milestone,
    required this.icon,
  });

  final String title;
  final String milestone;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: EidAppBar(title: title),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon, size: 72, color: EidColors.gold),
              const SizedBox(height: 16),
              Text(
                'هذه الميزة في الطريق',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: EidColors.darkGreen,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'متوفّرة في $milestone',
                style: const TextStyle(
                  fontSize: 14,
                  color: EidColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
