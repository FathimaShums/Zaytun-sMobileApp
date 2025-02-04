// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/food_list_screen.dart';
import 'screens/home/food_detail_screen.dart';
import 'screens/favorites/favorites_screen.dart';
import 'screens/cart/cart_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'shared/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      // This enables the app to switch between light and dark mode
      // based on system settings
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const FoodListScreen(),
        '/favorites': (context) => const FavoritesScreen(),
        '/cart': (context) => const CartScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
