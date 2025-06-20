// lib/pages/auth_check_page.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_page.dart';
import 'main_page.dart';

class AuthCheckPage extends StatefulWidget {
  const AuthCheckPage({super.key});

  @override
  State<AuthCheckPage> createState() => _AuthCheckPageState();
}

class _AuthCheckPageState extends State<AuthCheckPage> {
  @override
  void initState() {
    super.initState();
    // Inicia a verificação assim que a tela é construída
    _checkSessionAndNavigate();
  }

  Future<void> _checkSessionAndNavigate() async {
    final prefs = await SharedPreferences.getInstance();

    // Tenta ler o ID e o timestamp do último acesso
    final String? userId = prefs.getString('userId');
    final int? lastSessionTimestamp = prefs.getInt('lastSessionTimestamp');

    // Se não houver ID ou timestamp, o usuário nunca logou.
    if (userId == null || lastSessionTimestamp == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
      return;
    }

    final DateTime lastSessionDate = DateTime.fromMillisecondsSinceEpoch(
      lastSessionTimestamp,
    );
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(lastSessionDate);

    // Se a diferença for maior que 15 dias, a sessão expirou.
    if (difference.inDays >= 15) {
      // Opcional: Limpar os dados antigos antes de redirecionar
      await prefs.clear();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } else {
      // Sessão ativa, vai para a tela principal.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tela de carregamento simples enquanto a verificação acontece
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
