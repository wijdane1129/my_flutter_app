// lib/home_screen.dart (ou où que soit votre fichier)

import 'package:flutter/material.dart';
import '../nutrition/nutrition_screen.dart';
import '../activity/activity_screen.dart';
import '../profile/profile_screen.dart';
import '../goals/goals_screen.dart'; // Importer le nouvel écran
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex =
      2; // Mettre 2 pour que la page Goals soit la première affichée

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
      backgroundColor: Colors.white, // Set background to white
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
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.fitness_center),
            label: 'Activities',
            activeIcon: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6B45CC), Color(0xFF8B64E6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(8),
              child: const Icon(Icons.fitness_center, color: Colors.white),
            ),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.restaurant_menu),
            label: 'Nutrition',
            activeIcon: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6B45CC), Color(0xFF8B64E6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(8),
              child: const Icon(Icons.restaurant_menu, color: Colors.white),
            ),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.track_changes),
            label: 'Goals',
            activeIcon: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6B45CC), Color(0xFF8B64E6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(8),
              child: const Icon(Icons.track_changes, color: Colors.white),
            ),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: 'Profile',
            activeIcon: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6B45CC), Color(0xFF8B64E6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(8),
              child: const Icon(Icons.person, color: Colors.white),
            ),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.transparent,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.bold, color: const Color(0xFF6B45CC)),
        unselectedLabelStyle: GoogleFonts.poppins(color: Colors.grey),
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
    );
  }
}
