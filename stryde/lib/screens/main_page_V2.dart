import 'package:flutter/material.dart';
import 'package:stryde/screens/nutrition_page.dart';
import 'package:stryde/screens/profile_screen.dart';
import 'package:stryde/screens/progress_screen.dart';
import 'package:stryde/screens/goals_screen.dart';
import '../utils/constants.dart';

class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getCurrentDate(),
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.white,
              ),
            ),
            const Text(
              "Welcome, Tomás Anastacio",
              style: TextStyle(
                fontSize: 24,
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              child: const CircleAvatar(
                backgroundColor: Colors.white,
                radius: 18,
                child: Icon(Icons.person, color: AppColors.primaryGreen),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
        ),
        child: Stack(
          children: [
            // Green wave at top
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 100,
                decoration: const BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
              ),
            ),
            // Main content
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 120), //Alterar posição do menu
                  const SizedBox(height: 40), //Alterar altura do menu
                  // Main content cards
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      children: [
                        _buildFeatureCard(
                          icon: Icons.track_changes,
                          title: "Goals & Stats",
                          color: AppColors.primaryGreen,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const GoalsScreen(),
                              ),
                            );
                          },
                        ),
                        _buildFeatureCard(
                          icon: Icons.restaurant_menu,
                          title: "Nutrition",
                          color: AppColors.lightGreen,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MainPageV3(),
                              ),
                            );
                          },
                        ),
                        _buildFeatureCard(
                          icon: Icons.insights,
                          title: "Progress",
                          color: AppColors.lightGreen,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ProgressScreen(),
                              ),
                            );
                          },
                        ),
                        _buildFeatureCard(
                          icon: Icons.people,
                          title: "Community",
                          color: AppColors.primaryGreen,
                          onTap: () {
                            // Community functionality will be added later
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // Bottom navigation bar removed
    );
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    final weekdays = ['Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado', 'Domingo'];
    final months = ['janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho', 'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro'];
    
    final weekday = weekdays[now.weekday - 1]; // weekday is 1-7 in DateTime
    final day = now.day;
    final month = months[now.month - 1]; // month is 1-12 in DateTime
    
    return '$weekday, $day de $month';
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.7),
                color,
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: Colors.white,
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}