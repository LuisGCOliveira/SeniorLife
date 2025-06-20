import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'cadastro.dart';
import 'esqueciSenha.dart';
import 'menuDependentes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Senior Life',
      debugShowCheckedModeBanner: false,
      home: const TelaLogin(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('pt', 'BR'), Locale('en', 'US')],
    );
  }
}

class TelaLogin extends StatelessWidget {
  const TelaLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Container(
            constraints: const BoxConstraints.expand(),
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/imagens/backgroundSenior.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(child: _retanguloLogin(context)),
        ],
      ),
    );
  }

  Widget _retanguloLogin(BuildContext context) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6FF),
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(2, 4)),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Logo
            Image.asset('assets/imagens/logo.png', height: 70),
            const SizedBox(height: 10),

            // Texto de boas-vindas
            RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                children: [
                  TextSpan(text: 'Bem-vindo(a) ao '),
                  TextSpan(
                    text: 'Sênior',
                    style: TextStyle(color: Colors.blue),
                  ),
                  TextSpan(text: ' '),
                  TextSpan(
                    text: 'Life',
                    style: TextStyle(color: Colors.green),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // Campo E-mail
            const _CampoTexto(label: 'E-mail', hint: 'exemplo@gmail.com'),
            const SizedBox(height: 20),

            // Campo Senha
            const _CampoTexto(
              label: 'Senha',
              hint: 'Digite sua senha',
              isSenha: true,
            ),
            const SizedBox(height: 20),

            // Botões superiores
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TelaRecuperarSenha(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF31A2C6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    minimumSize: const Size(0, 42),
                  ),
                  child: const Text(
                    'Esqueci minha senha',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TelaCadastro(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF31A2C6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: const Text(
                    'Cadastre-se',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Botão Entrar
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TelaAdicionarDependente(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7AC77E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Entrar',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CampoTexto extends StatelessWidget {
  final String label;
  final String hint;
  final bool isSenha;

  const _CampoTexto({
    super.key,
    required this.label,
    required this.hint,
    this.isSenha = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Text(
            label,
            style: const TextStyle(color: Colors.black, fontSize: 18),
          ),
        ),
        const SizedBox(height: 5),
        SizedBox(
          height: 40,
          child: TextField(
            obscureText: isSenha,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFFFFAFA),
              hintText: hint,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Color(0xFF31A2C6)),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Color(0xFF31A2C6),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}
