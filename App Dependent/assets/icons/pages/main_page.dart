import 'package:flutter/material.dart';

import 'emergency_page.dart';
import 'food_page.dart';
import 'medication_page.dart';
import 'physical_activity_page.dart';

class MainPage extends StatelessWidget {
  final Color backgroundColor = const Color(0xFFF5F6FF);

  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 150), // Espaço do topo até a logo
            // Logo
            const CircleAvatar(
              radius: 60,
              backgroundImage: AssetImage('assets/icons/logo.png'),
              backgroundColor: Colors.transparent,
            ),

            const SizedBox(height: 60), // Espaço entre logo e texto
            // Texto de boas-vindas
            Center(
              child: RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  text: 'Bem-vindo(a) ao ',
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(
                      text: 'Sênior ',
                      style: TextStyle(color: Colors.blue),
                    ),
                    TextSpan(
                      text: 'Life',
                      style: TextStyle(color: Colors.green),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20), // Espaço entre texto e botões
            // Botões
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 75),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 20,
                    runSpacing: 20,
                    children: [
                      MenuCardButton(
                        color: const Color(0xFF007292),
                        imagePath: 'assets/icons/medication.png',
                        text: 'Medicação',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MedicationPage(),
                            ),
                          );
                        },
                      ),
                      MenuCardButton(
                        color: const Color(0xFF00AD40),
                        imagePath: 'assets/icons/food.png',
                        text: 'Alimentação',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FoodPage(),
                            ),
                          );
                        },
                      ),
                      MenuCardButton(
                        color: const Color(0xFFDC7F04),
                        imagePath: 'assets/icons/physical_activity.png',
                        text: 'Atv. Física',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const PhysicalActivityPage(),
                            ),
                          );
                        },
                      ),
                      MenuCardButton(
                        color: const Color(0xFFFF0000),
                        imagePath: 'assets/icons/emergency.png',
                        text: 'Emergência',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EmergencyPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MenuCardButton extends StatelessWidget {
  final Color color;
  final String imagePath;
  final String text;
  final VoidCallback onTap;

  const MenuCardButton({
    super.key,
    required this.color,
    required this.imagePath,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 180,
        height: 160,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath, width: 80, height: 80, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
