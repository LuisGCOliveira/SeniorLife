import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'main_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _performLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final url = Uri.parse(
        'https://sua-api.com.br/login',
      ); // <<< SUBSTITUA AQUI

      // --- CONTRATO DE DADOS (JSON): ENVIO PARA API DE LOGIN ---
      // Ao clicar em Entrar, o Flutter monta e envia para a API um JSON
      // com o seguinte formato:
      //
      // {
      //   "email": "email_digitado_pelo_usuario@email.com",
      //   "senha": "senha_digitada_pelo_usuario"
      // }
      //
      // O backend deve estar preparado para receber um objeto com essas chaves.
      // -----------------------------------------------------------
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(<String, String>{
          'email': _emailController.text,
          'senha': _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        // --- CONTRATO DE DADOS (JSON): RESPOSTA DA API DE LOGIN ---
        // Se o login for bem-sucedido (statusCode 200), o Flutter espera
        // receber da API um JSON com, no mínimo, a chave "userId":
        //
        // {
        //   "userId": "string_unica_do_usuario", // Ex: "60b8d295f1d2c2001c8e4e6a"
        //   "userName": "Nome do Usuário"        // (Opcional, pode ter mais dados)
        // }
        // -------------------------------------------------------------
        final responseData = jsonDecode(response.body);
        final userIdFromApi = responseData['userId'];

        if (userIdFromApi == null) {
          _showErrorSnackbar('Resposta inválida do servidor (userId ausente).');
          return;
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', userIdFromApi);
        await prefs.setInt(
          'lastSessionTimestamp',
          DateTime.now().millisecondsSinceEpoch,
        );

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainPage()),
          );
        }
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        _showErrorSnackbar('E-mail ou senha inválidos.');
      } else {
        _showErrorSnackbar('Erro no servidor. Tente novamente mais tarde.');
      }
    } catch (e) {
      _showErrorSnackbar('Erro de conexão. Verifique sua internet.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/elements/top_wave.png',
              fit: BoxFit.cover,
            ),
          ),
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
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F4FF),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 12,
                      offset: const Offset(2, 4),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Image.asset('assets/icons/logo.png', height: 60),
                      const SizedBox(height: 16),
                      RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
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
                      const SizedBox(height: 24),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'E-mail',
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBFB),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF39A9D9)),
                        ),
                        child: TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                            hintText: 'exemplo@email.com',
                            hintStyle: TextStyle(color: Colors.black26),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, digite seu e-mail';
                            }
                            final emailRegex = RegExp(
                              r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                            );
                            if (!emailRegex.hasMatch(value)) {
                              return 'Por favor, digite um e-mail válido';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Senha',
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBFB),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF39A9D9)),
                        ),
                        child: Stack(
                          alignment: Alignment.centerRight,
                          children: [
                            TextFormField(
                              controller: _passwordController,
                              obscureText: !_isPasswordVisible,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.fromLTRB(
                                  12,
                                  14,
                                  48,
                                  14,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return 'Por favor, digite sua senha';
                                return null;
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: const Color(0xFF39A9D9),
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2D9CBA),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: const BorderSide(
                              color: Color(0xFF13698C),
                              width: 3,
                            ),
                          ),
                        ),
                        onPressed: _isLoading ? null : _performLogin,
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                              )
                            : const Text(
                                'Entrar',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MainPage(),
                            ),
                          );
                        },
                        child: const Text(
                          '[ Acesso DEV ]',
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
