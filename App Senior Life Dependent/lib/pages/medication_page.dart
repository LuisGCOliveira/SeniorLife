import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // ADICIONADO

class MedicationItem {
  final String id;
  final String time;
  final String medication;
  final String info;
  bool checked;

  MedicationItem({
    required this.id,
    required this.time,
    required this.medication,
    required this.info,
    this.checked = false,
  });

  factory MedicationItem.fromJson(Map<String, dynamic> json) {
    return MedicationItem(
      id: json['id'] as String,
      time: json['time'] as String,
      medication: json['name'] as String,
      info: json['description'] as String,
      checked: json['checked'] as bool? ?? false,
    );
  }
}

class MedicationPage extends StatefulWidget {
  const MedicationPage({super.key});

  @override
  State<MedicationPage> createState() => _MedicationPageState();
}

class _MedicationPageState extends State<MedicationPage> {
  // ADICIONADO: Variável para armazenar o ID do usuário
  String? _userId;

  List<MedicationItem> medicationItems = [];
  bool isLoading = true;
  String? error;

  final TextStyle _popupTextStyle = const TextStyle(fontSize: 22);

  @override
  void initState() {
    super.initState();
    // ADICIONADO: Carrega o ID do usuário antes de buscar os itens
    _loadUserIdAndFetchItems();
  }

  // ADICIONADO: Função para carregar o ID do usuário e depois buscar os itens
  Future<void> _loadUserIdAndFetchItems() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString('userId');
    });

    if (_userId == null) {
      setState(() {
        error =
            "Não foi possível identificar o usuário. Tente fazer login novamente.";
        isLoading = false;
      });
      return;
    }
    // Após carregar o ID, busca os itens de medicação
    _fetchMedicationItems();
  }

  /// Busca a lista de medicamentos do usuário logado na API.
  Future<void> _fetchMedicationItems() async {
    if (_userId == null) return;

    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      // --- CONTRATO DE DADOS: BUSCAR ITENS (GET) ---
      // 1. ENDPOINT: A URL para buscar os medicamentos do usuário.
      //    A API deve filtrar os resultados pelo 'userId' enviado como
      //    um "query parameter" (ex: /medications?userId=...).
      //    [!] SUBSTITUA A URL ABAIXO PELA SUA URL REAL.
      //
      // 2. RESPOSTA (JSON): Se a busca for bem-sucedida (statusCode 200),
      //    a API deve retornar uma LISTA de objetos com o seguinte formato:
      //
      // [
      //   {
      //     "id": "string_unica_do_item",
      //     "time": "08:00",
      //     "name": "Nome do Remédio",
      //     "description": "Descrição e dosagem do remédio.",
      //     "checked": false
      //   },
      //   ... outros itens
      // ]
      // ---------------------------------------------------
      final url = Uri.parse(
        'https://sua-api.com.br/medications?userId=$_userId',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        setState(() {
          medicationItems = jsonList
              .map((json) => MedicationItem.fromJson(json))
              .toList();
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Falha ao carregar medicamentos: ${response.statusCode}.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Ocorreu um erro de conexão. Verifique sua internet.';
        isLoading = false;
      });
    }
  }

  /// Envia a atualização do status de um item para a API.
  Future<void> _updateMedicationItemStatus(String id, bool newStatus) async {
    if (_userId == null) return;

    try {
      // --- CONTRATO DE DADOS: ATUALIZAR ITEM (PUT ou PATCH) ---
      // 1. ENDPOINT: A URL para atualizar um medicamento específico.
      //    A API deve identificar o item pelo 'id' passado na URL
      //    (ex: /medications/id_do_item).
      //    [!] SUBSTITUA A URL ABAIXO PELA SUA URL REAL.
      //
      // 2. REQUISIÇÃO (JSON): O Flutter envia um JSON no corpo ('body')
      //    com os dados a serem atualizados e o 'userId' para autorização.
      //    Formato:
      //
      // {
      //   "checked": true,  // ou false
      //   "userId": "id_do_usuario_logado"
      // }
      //
      // 3. RESPOSTA: A API deve confirmar o sucesso com um statusCode 200.
      // ---------------------------------------------------
      final url = Uri.parse('https://sua-api.com.br/medications/$id');

      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(<String, dynamic>{
          'checked': newStatus,
          'userId': _userId,
        }),
      );

      if (response.statusCode == 200) {
        print(
          'Status do item $id (Medicação) atualizado com sucesso para $newStatus',
        );
      } else {
        throw Exception('Falha ao atualizar status na API');
      }
    } catch (e) {
      // Reverte a mudança na UI em caso de falha
      setState(() {
        final itemIndex = medicationItems.indexWhere((item) => item.id == id);
        if (itemIndex != -1) {
          medicationItems[itemIndex].checked = !newStatus;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao salvar alteração. Tente novamente.'),
        ),
      );
      print('Erro ao atualizar status do item $id (Medicação): $e');
    }
  }

  void _showMedicationInfo(
    BuildContext context,
    String medicationName,
    String medicationInfo,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Informações sobre:\n$medicationName',
            style: _popupTextStyle.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: SingleChildScrollView(
            child: Text(
              medicationInfo,
              style: _popupTextStyle,
              textAlign: TextAlign.center,
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Fechar',
                style: _popupTextStyle.copyWith(color: Colors.blue),
              ), // Cor ajustada
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: Column(
              children: [
                const SizedBox(height: 40),
                Center(
                  child: RichText(
                    text: const TextSpan(
                      text: 'Como está sua ',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      children: [
                        TextSpan(
                          text: 'Medicação',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: '?',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const SizedBox(width: 40 + 16),
                      SizedBox(
                        width: 80,
                        child: Text(
                          'Horário',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Remédio',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const SizedBox(width: 36),
                    ],
                  ),
                ),
                const Divider(thickness: 1),
                Expanded(child: _buildBody()),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                SizedBox(
                  height: 100,
                  width: double.infinity,
                  child: Image.asset(
                    'assets/elements/footer.png',
                    fit: BoxFit.fill,
                  ),
                ),
                Positioned(
                  bottom: 20,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: SizedBox(
                      width: 60,
                      height: 60,
                      child: Image.asset(
                        'assets/icons/home.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                error!,
                style: const TextStyle(color: Colors.red, fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _fetchMedicationItems,
                child: const Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
      );
    }
    if (medicationItems.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum medicamento encontrado.',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 120),
      itemCount: medicationItems.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final item = medicationItems[index];
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                setState(() => item.checked = !item.checked);
                _updateMedicationItemStatus(item.id, item.checked);
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(border: Border.all(width: 2)),
                child: item.checked
                    ? const Icon(Icons.check, color: Colors.green, size: 35.0)
                    : null,
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 60,
              child: Text(
                item.time,
                style: const TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                item.medication,
                style: const TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 36,
              height: 36,
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: Image.asset(
                  'assets/icons/info_icon.png',
                  fit: BoxFit.contain,
                ),
                onPressed: () =>
                    _showMedicationInfo(context, item.medication, item.info),
              ),
            ),
          ],
        );
      },
    );
  }
}
