import 'package:flutter/material.dart';

class PhysicalActivityPage extends StatelessWidget {
  const PhysicalActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Atividade Física')),
      body: const Center(child: Text('Tela de Ativdades Fisicas')),
    );
  }
}