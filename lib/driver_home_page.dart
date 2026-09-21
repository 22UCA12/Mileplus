import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_page.dart';
import 'profile_page.dart';

class DriverHomePage extends StatefulWidget {
  const DriverHomePage({super.key});

  @override
  State<DriverHomePage> createState() =>
      _DriverHomePageState();
}

class _DriverHomePageState
    extends State<DriverHomePage> {

  int selectedIndex = 0;

  // ==========================================================
  // LOGOUT
  // ==========================================================

  Future<void> logout() async {

    final confirm = await showDialog<bool>(
      context: context,

      builder: (context) {

        return AlertDialog(

          title: const Text(
            'Logout',
          ),

          content: const Text(
            'Do you want to logout?',
          ),

          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },

              child: const Text(
                'Cancel',
              ),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },

              child: const Text(
                'Logout',
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) {
      return;
    }

    final prefs =
    await SharedPreferences.getInstance();

    await prefs.clear();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,

      MaterialPageRoute(
        builder: (context) =>
        const LoginPage(),
      ),

          (route) => false,
    );
  }


  // ==========================================================
  // BOTTOM NAVIGATION
  // ==========================================================

  void onBottomNavigationTap(
      int index) {

    setState(() {
      selectedIndex = index;
    });

    if (index == 1) {

      Navigator.push(
        context,

        MaterialPageRoute(
          builder: (context) =>
          const ProfilePage(),
        ),
      ).then((_) {

        if (mounted) {

          setState(() {
            selectedIndex = 0;
          });
        }
      });
    }
  }


  // ==========================================================
  // HOME - EMPTY
  // ==========================================================

  Widget emptyHome() {

    return const SizedBox.expand();
  }


  // ==========================================================
  // UI
  // ==========================================================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
      Colors.white,


      // ======================================================
      // NO APP BAR
      // NO MILEPLUS
      // NO TOP PROFILE ICON
      // ======================================================

      body: emptyHome(),


      // ======================================================
      // BOTTOM NAVIGATION
      // ======================================================

      bottomNavigationBar:
      NavigationBar(

        selectedIndex:
        selectedIndex,

        onDestinationSelected:
        onBottomNavigationTap,

        backgroundColor:
        Colors.white,

        indicatorColor:
        const Color(0xFFDFF3E8),

        destinations: const [

          // ==================================================
          // HOME
          // ==================================================

          NavigationDestination(

            icon: Icon(
              Icons.home_outlined,
            ),

            selectedIcon: Icon(
              Icons.home_rounded,
            ),

            label: 'Home',
          ),


          // ==================================================
          // PROFILE
          // ==================================================

          NavigationDestination(

            icon: Icon(
              Icons.person_outline_rounded,
            ),

            selectedIcon: Icon(
              Icons.person_rounded,
            ),

            label: 'Profile',
          ),
        ],
      ),
    );
  }
}