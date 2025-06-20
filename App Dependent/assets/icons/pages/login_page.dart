import 'package:flutter/material.dart';
import 'package:meu_app/pages/main_page.dart'; // Certifique-se de ajustar o nome do seu projeto

void main() {
  runApp(SeniorLifeApp());
}

class SeniorLifeApp extends StatelessWidget {
  const SeniorLifeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: LoginPage());
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Imagem de topo
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/elements/top_wave.png',
              fit: BoxFit.cover,
            ),
          ),
          // Imagem de fundo
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/elements/bottom_wave.png',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(24),
                margin: EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: Color(0xFFF4F4FF),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 12,
                      offset: Offset(2, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/icons/logo.png', height: 60),
                    SizedBox(height: 16),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: 'Bem-vindo(a) ao ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 18,
                        ),
                        children: [
                          TextSpan(
                            text: 'Sênior ',
                            style: TextStyle(
                              color: Color(0xFF39A9D9),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: 'Life',
                            style: TextStyle(
                              color: Color(0xFF78B843),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),

                    // Campo Usuário
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Usuário',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xFFFFFBFB),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Color(0xFF39A9D9)),
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 16),

                    // Campo Senha
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Senha',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xFFFFFBFB),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Color(0xFF39A9D9)),
                      ),
                      child: TextField(
                        obscureText: true,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 24),

                    // Botão Entrar
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF2D9CBA),
                        padding: EdgeInsets.symmetric(
                          horizontal: 48,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: Color(0xFF13698C), width: 3),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MainPage()),
                        );
                      },
                      child: Text(
                        'Entrar',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
