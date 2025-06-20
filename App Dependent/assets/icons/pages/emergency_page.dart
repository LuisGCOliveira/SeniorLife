import 'dart:convert'; // Importar para decodificar JSON

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Importar o pacote http

// Definindo a classe MedicalInfo diretamente neste arquivo
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

  // Método de fábrica para criar uma instância de MedicalInfo a partir de um JSON (Map)
  factory MedicalInfo.fromJson(Map<String, dynamic> json) {
    return MedicalInfo(
      name: json['name'] as String,
      age: json['age'] as int,
      allergies: json['allergies'] as String,
      history: json['history'] as String,
      emergencyContact: json['emergencyContact'] as String,
    );
  }
}

class EmergencyPage extends StatelessWidget {
  const EmergencyPage({super.key});

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        title: const Text(
          'Você deseja cancelar a ajuda ?',
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
                    onPressed: () {
                      Navigator.of(context).pop(); // Fecha o popup
                      Navigator.of(context).pop(); // Volta para a tela anterior
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF26B0B6),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
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
                      shape: RoundedRectangleBorder(
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

  // FUNÇÃO: Para buscar as informações médicas da API
  Future<MedicalInfo> _fetchMedicalInfo() async {
    // ##################################################################
    // IMPORTANTE: SUBSTITUA ESTA URL PELA SUA URL REAL DA API BACKEND!
    // Exemplo: 'http://localhost:3000/api/medical_info' ou 'https://seusite.com/api/medical_info'
    // Se for localhost, use o IP da sua máquina ou '10.0.2.2' para emuladores Android.
    // ##################################################################
    final url = Uri.parse(
      'https://api.example.com/medical_info',
    ); // SUBSTITUA AQUI!

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
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Informações Médicas'),
          content: FutureBuilder<MedicalInfo>(
            future: _fetchMedicalInfo(), // Chama a função para buscar os dados
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
                return Text(
                  'Nome: ${info.name}\n'
                  'Idade: ${info.age} anos\n'
                  'Alergias: ${info.allergies}\n'
                  'Histórico: ${info.history}\n'
                  'Contato de emergência: ${info.emergencyContact}',
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

    return Scaffold(
      backgroundColor: Colors.red,
      body: SafeArea(
        child: Stack(
          children: [
            // Texto "Pedindo Ajuda..." posicionado no topo centralizado
            Positioned(
              top: screenHeight * 0.10, // 10% da altura da tela (ajustado)
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

            // Ícone ambulância posicionado
            Positioned(
              top: screenHeight * 0.40, // 40% da altura da tela
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
                    width: screenWidth * 0.25, // 25% da largura da tela
                    height:
                        screenWidth *
                        0.25, // Mantém a proporção (largura = altura)
                  ),
                ),
              ),
            ),

            // Botão X no topo direito
            Positioned(
              top: screenHeight * 0.02, // 2% da altura da tela
              right: screenWidth * 0.04, // 4% da largura da tela
              child: GestureDetector(
                onTap: () => _showCancelDialog(context),
                child: Container(
                  width: screenWidth * 0.12, // 12% da largura da tela
                  height: screenWidth * 0.12, // Mantém a proporção circular
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: const Center(
                    child: Text(
                      'X',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize:
                            24, // Considere ajustar também para responsividade
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Botão de informações médicas no rodapé
            Positioned(
              bottom: screenHeight * 0.03, // 3% da altura da tela
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
                      size: screenWidth * 0.08, // 8% da largura da tela
                    ),
                    SizedBox(
                      height: screenHeight * 0.005,
                    ), // 0.5% da altura da tela
                    const Text(
                      'Informações Médicas',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize:
                            16, // Considere ajustar também para responsividade
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
