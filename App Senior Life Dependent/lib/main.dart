// lib/main.dart

import 'package:flutter/material.dart';
// IMPORTANTE: Importe a nova página de verificação
import 'package:meu_app/pages/auth_check_page.dart'; 

void main() {
  runApp(const SeniorLifeApp());
}

class SeniorLifeApp extends StatelessWidget {
  const SeniorLifeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      // A home agora é a nossa tela de verificação!
      home: AuthCheckPage(),
    );
  }
}