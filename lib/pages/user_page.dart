import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../utils/navigation_utils.dart';
import '../widgets/app_bottom_nav_bar.dart';
import '../widgets/app_gradient_background.dart';

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      NavigationUtils.handleBottomNav(context, AppNavDestination.home);
      return const SizedBox.shrink();
    }

    return Scaffold(
      bottomNavigationBar: AppBottomNavBar(
        current: AppNavDestination.user,
        onNavigate: (destination) =>
            NavigationUtils.handleBottomNav(context, destination),
      ),
      body: AppGradientBackground(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 48),
            CircleAvatar(
              radius: 48,
              backgroundImage:
                  user.photoURL != null ? NetworkImage(user.photoURL!) : null,
              child: user.photoURL == null
                  ? Text(
                      user.displayName?.substring(0, 1).toUpperCase() ?? '?',
                      style: const TextStyle(fontSize: 32),
                    )
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              user.displayName ?? 'Anonymous Athlete',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              user.email ?? 'No email linked',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            ListTile(
              leading: const Icon(Icons.badge),
              title: const Text('Account Provider'),
              subtitle: Text(user.providerData.isNotEmpty
                  ? user.providerData.first.providerId
                  : 'Unknown'),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Member Since'),
              subtitle: Text(user.metadata.creationTime?.toString() ?? 'N/A'),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (!context.mounted) return;
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              icon: const Icon(Icons.logout),
              label: const Text('Sign Out'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
