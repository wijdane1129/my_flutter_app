// lib/home_screen.dart (ou où que soit votre fichier)

import 'package:flutter/material.dart';
import '../nutrition/nutrition_screen.dart';
import '../activity/activity_screen.dart';
import '../profile/profile_screen.dart';
import '../goals/goals_screen.dart'; // Importer le nouvel écran

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 2; // Mettre 2 pour que la page Goals soit la première affichée

  final List<Widget> _screens = [
    const ActivityScreen(), // Index 0
    const NutritionScreen(), // Index 1
    const GoalsScreen(), // Index 2 - Remplacer le placeholder
    const ProfileScreen(), // Index 3
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // L'AppBar est maintenant gérée dans chaque écran individuellement
      // pour plus de flexibilité (comme le titre "Your Goals")
      // appBar: AppBar(
      //   title: const Text('Fitness App'),
      // ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Activités',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Nutrition',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.track_changes),
            label: 'Goals',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person), 
            label: 'Profil'
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
      ),
    );
  }
}
