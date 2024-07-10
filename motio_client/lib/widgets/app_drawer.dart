import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motio_client/providers/user_provider.dart';
import 'package:motio_client/services/auth_service.dart';

import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/recipe_categories_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/shopping_list_screen.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(userProvider);

    return Drawer(
      child: Container(
        color: theme.colorScheme.surface,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                gradient: LinearGradient(
                  colors: [theme.colorScheme.primary, theme.colorScheme.surface],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/icon/icon.png',
                    width: 80,
                    height: 80,
                  ),
                  const SizedBox(height: 10),
                  if (user != null) ...[
                    Text(
                      '${user.firstName} ${user.lastName}',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.home, color: theme.colorScheme.primary),
              title: Text('Strona główna', style: theme.textTheme.bodyLarge),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.fastfood, color: theme.colorScheme.primary),
              title: Text('Przepisy', style: theme.textTheme.bodyLarge),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const RecipeCategoriesScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.shopping_bag_outlined, color: theme.colorScheme.primary),
              title: Text('Lista zakupów', style: theme.textTheme.bodyLarge),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const ShoppingListScreen()),
                );
              },
            ),
            // ListTile(
            //   leading: Icon(Icons.calendar_month_outlined, color: theme.colorScheme.primary),
            //   title: Text('Kalendarz', style: theme.textTheme.bodyLarge),
            // ),
            // ListTile(
            //   leading: Icon(Icons.note_alt_outlined, color: theme.colorScheme.primary),
            //   title: Text('Notatki', style: theme.textTheme.bodyLarge),
            // ),
            ListTile(
              leading: Icon(Icons.settings, color: theme.colorScheme.primary),
              title: Text('Ustawienia', style: theme.textTheme.bodyLarge),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout, color: theme.colorScheme.primary),
              title: Text('Wyloguj się', style: theme.textTheme.bodyLarge),
              onTap: () async {
                await AuthService().logout();
                ref.read(userProvider.notifier).clearUser();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
