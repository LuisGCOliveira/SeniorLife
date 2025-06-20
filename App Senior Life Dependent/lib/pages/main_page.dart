import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'emergency_page.dart';
import 'food_page.dart';
import 'medication_page.dart';
import 'physical_activity_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final Color backgroundColor = const Color(0xFFF5F6FF);
  String? _userId; // Variável para armazenar o ID do usuário

  @override
  void initState() {
    super.initState();
    _loadUserDataAndRefreshSession(); // Carrega os dados do usuário e renova a sessão
  }

  /// Função para carregar o userId e renovar a sessão
  Future<void> _loadUserDataAndRefreshSession() async {
    // --- CONTRATO DE DADOS (JSON): RESPOSTA DA API DE LOGIN ---
    // Esta função depende do 'userId' que foi salvo no SharedPreferences
    // pela tela de Login. A tela de Login, por sua vez, espera receber
    // da API de Login um JSON no seguinte formato em caso de sucesso:
    //
    // {
    //   "userId": "string_unica_do_usuario", // Ex: "60b8d295f1d2c2001c8e4e6a"
    //   "userName": "Nome do Usuário",         // (Opcional, pode ter mais dados)
    //   "token": "jwt_token_se_existir"      // (Opcional, para autenticação)
    // }
    //
    // O código na LoginPage extrai o valor da chave "userId" e o salva.
    // Esta função então lê esse valor salvo.
    // ---------------------------------------------------------

    final prefs = await SharedPreferences.getInstance();

    // Renova o timestamp da sessão para o momento atual
    await prefs.setInt(
      'lastSessionTimestamp',
      DateTime.now().millisecondsSinceEpoch,
    );
    print('Sessão do usuário renovada.');

    // Lê o 'userId' que foi salvo no dispositivo durante o login.
    setState(() {
      _userId = prefs.getString('userId');
      print('User ID carregado: $_userId');
    });
  }

  /// Função para enviar o alerta de emergência ao backend
  Future<void> _sendEmergencyAlert(BuildContext context) async {
    if (_userId == null || _userId!.isEmpty) {
      print('Erro: User ID não disponível ou inválido para enviar alerta.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não foi possível identificar o usuário. Tente reiniciar o app.',
          ),
        ),
      );
      return;
    }

    final url = Uri.parse(
      'https://sua-api.com.br/emergency_alert',
    ); // SUBSTITUA AQUI!

    try {
      // --- CONTRATO DE DADOS (JSON): ENVIO DO ALERTA DE EMERGÊNCIA ---
      // Ao enviar o alerta, o Flutter monta e envia para a API um JSON
      // no seguinte formato:
      //
      // {
      //   "message": "Alerta de emergência acionado pelo app.",
      //   "userId": "o_id_do_usuario_logado",      // Ex: "60b8d295f1d2c2001c8e4e6a"
      //   "timestamp": "2025-06-17T13:24:46.123Z" // Data e hora no formato ISO 8601
      // }
      //
      // O backend deve estar preparado para receber um objeto com essas chaves.
      // --------------------------------------------------------------------
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'message': 'Alerta de emergência acionado pelo app.',
          'userId': _userId!,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('Alerta de emergência enviado com sucesso! User ID: $_userId');
      } else {
        print(
          'Falha ao enviar alerta: ${response.statusCode}, ${response.body}',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao enviar alerta. Tente novamente.'),
          ),
        );
      }
    } catch (e) {
      print('Erro de conexão ao enviar alerta de emergência: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro de conexão. Verifique sua internet.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 150),
            const CircleAvatar(
              radius: 60,
              backgroundImage: AssetImage('assets/icons/logo.png'),
              backgroundColor: Colors.transparent,
            ),
            const SizedBox(height: 60),
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
            const SizedBox(height: 20),
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
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MedicationPage(),
                          ),
                        ),
                      ),
                      MenuCardButton(
                        color: const Color(0xFF00AD40),
                        imagePath: 'assets/icons/food.png',
                        text: 'Alimentação',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FoodPage(),
                          ),
                        ),
                      ),
                      MenuCardButton(
                        color: const Color(0xFFDC7F04),
                        imagePath: 'assets/icons/physical_activity.png',
                        text: 'Atv. Física',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PhysicalActivityPage(),
                          ),
                        ),
                      ),
                      MenuCardButton(
                        color: const Color(0xFFFF0000),
                        imagePath: 'assets/icons/emergency.png',
                        text: 'Emergência',
                        onTap: () {
                          _sendEmergencyAlert(context);
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

// O widget MenuCardButton permanece o mesmo.
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
