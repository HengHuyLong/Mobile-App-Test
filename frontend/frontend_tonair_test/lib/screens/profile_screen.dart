import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TITLE
          Text(
            'Profile',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 24),

          // USER INFO (PLACEHOLDER)
          Row(
            children: [
              const CircleAvatar(
                radius: 28,
                backgroundColor: Colors.black,
                child: Icon(Icons.person, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('User', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text('Logged in', style: theme.textTheme.bodySmall),
                ],
              ),
            ],
          ),

          const SizedBox(height: 40),

          // LOGOUT BUTTON
          SizedBox(
            width: double.infinity,
            height: 48,
            child: GestureDetector(
              onTap: () {
                ref.read(authProvider.notifier).logout();
              },
              child: Container(
                alignment: Alignment.center,
                color: Colors.black,
                child: const Text(
                  'LOG OUT',
                  style: TextStyle(
                    color: Colors.white,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
