import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// O modelo de dados MedicalInfo não precisa de alterações.
class MedicalInfo {
  final String name;
  final int age;
  final String allergies;
  final String history;
  final String emergencyContact;

  MedicalInfo({
    required this.name,
    required this.age,
    required this.allergies,
    required this.history,
    required this.emergencyContact,
  });

  factory MedicalInfo.fromJson(Map<String, dynamic> json) {
    return MedicalInfo(
      name: json['name'] ?? 'Não informado',
      age: json['age'] ?? 0,
      allergies: json['allergies'] ?? 'Não informado',
      history: json['history'] ?? 'Não informado',
      emergencyContact: json['emergencyContact'] ?? 'Não informado',
    );
  }
}

class EmergencyPage extends StatefulWidget {
  const EmergencyPage({super.key});

  @override
  State<EmergencyPage> createState() => _EmergencyPageState();
}

class _EmergencyPageState extends State<EmergencyPage> {
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString('userId');
      if (_userId == null) {
        print("ERRO CRÍTICO: userId não encontrado na EmergencyPage.");
      }
    });
  }

  Future<void> _sendCancelAlert() async {
    // A lógica desta função permanece a mesma.
    if (_userId == null || _userId!.isEmpty) {
      print('Não foi possível cancelar o alerta: userId ausente.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao cancelar: ID do usuário não encontrado.'),
        ),
      );
      return;
    }
    final url = Uri.parse('https://sua-api.com.br/cancel_alert');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'userId': _userId}),
      );
      if (response.statusCode == 200) {
        print('Alerta cancelado com sucesso no backend.');
      } else {
        print(
          'Falha ao comunicar cancelamento ao backend: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Erro de conexão ao tentar cancelar alerta: $e');
    }
  }

  void _showCancelDialog(BuildContext context) {
    // A lógica desta função permanece a mesma.
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        title: const Text(
          'Você deseja cancelar a ajuda?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.black,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await _sendCancelAlert();
                      if (mounted) {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF26B0B6),
                      foregroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      minimumSize: const Size(120, 0),
                    ),
                    child: const Text(
                      'Sim',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      minimumSize: const Size(120, 0),
                    ),
                    child: const Text(
                      'Não',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<MedicalInfo> _fetchMedicalInfo() async {
    // A lógica desta função permanece a mesma.
    if (_userId == null || _userId!.isEmpty) {
      throw Exception(
        'ID do usuário não está disponível para buscar informações.',
      );
    }
    final url = Uri.parse('https://sua-api.com.br/medical_info/$_userId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return MedicalInfo.fromJson(jsonDecode(response.body));
      } else {
        throw Exception(
          'Falha ao carregar informações médicas. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Erro de conexão ou ao processar dados: $e');
    }
  }

  void _showMedicalInfoDialog(BuildContext context) {
    // A lógica desta função permanece a mesma.
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Informações Médicas'),
          content: FutureBuilder<MedicalInfo>(
            future: _fetchMedicalInfo(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 100,
                  child: Center(child: CircularProgressIndicator()),
                );
              } else if (snapshot.hasError) {
                return Text('Erro: ${snapshot.error}');
              } else if (snapshot.hasData) {
                final MedicalInfo info = snapshot.data!;
                return SingleChildScrollView(
                  child: Text(
                    'Nome: ${info.name}\nIdade: ${info.age} anos\n'
                    'Alergias: ${info.allergies}\nHistórico: ${info.history}\n'
                    'Contato de emergência: ${info.emergencyContact}',
                  ),
                );
              } else {
                return const Text('Nenhuma informação disponível.');
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // =======================================================================
    // ADICIONADO: O WIDGET POPSCOPE PARA BLOQUEAR O BOTÃO "VOLTAR"
    // =======================================================================
    return PopScope(
      // canPop: false impede que o usuário volte usando o gesto ou o botão do sistema.
      canPop: false,

      // onPopInvoked é chamado quando o usuário TENTA voltar.
      // O parâmetro 'didPop' será false porque nós bloqueamos a ação com 'canPop: false'.
      onPopInvoked: (bool didPop) {
        if (didPop) return;
        // Mostra uma mensagem rápida explicando como sair da tela.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Para cancelar a ajuda, por favor, use o botão "X" no topo da tela.',
            ),
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: Scaffold(
        backgroundColor: const Color(
          0xFFFF0000,
        ), // Cor de fundo ajustada para o vermelho correto
        body: SafeArea(
          child: Stack(
            children: [
              // Todos os outros widgets da sua UI continuam aqui dentro...
              Positioned(
                top: screenHeight * 0.10,
                left: 0,
                right: 0,
                child: const Center(
                  child: Text(
                    'Pedindo Ajuda...',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: screenHeight * 0.40,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(30),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE0E0E0),
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      'assets/icons/ambulance.png',
                      width: screenWidth * 0.25,
                      height: screenWidth * 0.25,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: screenHeight * 0.02,
                right: screenWidth * 0.04,
                child: GestureDetector(
                  onTap: () => _showCancelDialog(context),
                  child: Container(
                    width: screenWidth * 0.12,
                    height: screenWidth * 0.12,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: const Center(
                      child: Text(
                        'X',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: screenHeight * 0.03,
                left: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => _showMedicalInfoDialog(context),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.keyboard_arrow_up,
                        color: Colors.white,
                        size: screenWidth * 0.08,
                      ),
                      SizedBox(height: screenHeight * 0.005),
                      const Text(
                        'Informações Médicas',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
