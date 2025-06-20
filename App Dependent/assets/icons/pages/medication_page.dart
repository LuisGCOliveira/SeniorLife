import 'package:flutter/material.dart';

class MedicationPage extends StatelessWidget {
  const MedicationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Medicação')),
      body: const Center(child: Text('Tela de Medicação')),
    );
  }
}