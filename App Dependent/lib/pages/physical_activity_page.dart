import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // ADICIONADO

class ActivityItem {
  final String id;
  final String time;
  final String activity;
  final String info;
  bool checked;

  ActivityItem({
    required this.id,
    required this.time,
    required this.activity,
    required this.info,
    this.checked = false,
  });

  factory ActivityItem.fromJson(Map<String, dynamic> json) {
    return ActivityItem(
      id: json['id'] as String,
      time: json['time'] as String,
      activity: json['name'] as String,
      info: json['description'] as String,
      checked: json['checked'] as bool? ?? false,
    );
  }
}

class PhysicalActivityPage extends StatefulWidget {
  const PhysicalActivityPage({super.key});

  @override
  State<PhysicalActivityPage> createState() => _PhysicalActivityPageState();
}

class _PhysicalActivityPageState extends State<PhysicalActivityPage> {
  // ADICIONADO: Variável para armazenar o ID do usuário
  String? _userId;

  List<ActivityItem> activityItems = [];
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
    // Após carregar o ID, busca os itens
    _fetchActivityItems();
  }

  /// Busca a lista de atividades do usuário logado na API.
  Future<void> _fetchActivityItems() async {
    if (_userId == null) return;

    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      // --- CONTRATO DE DADOS: BUSCAR ATIVIDADES (GET) ---
      // 1. ENDPOINT: A URL para buscar as atividades do usuário.
      //    A API deve filtrar os resultados pelo 'userId' enviado como
      //    um "query parameter" (ex: /activities?userId=...).
      //    [!] SUBSTITUA A URL ABAIXO PELA SUA URL REAL.
      //
      // 2. RESPOSTA (JSON): Se a busca for bem-sucedida (statusCode 200),
      //    a API deve retornar uma LISTA de objetos com o seguinte formato:
      //
      // [
      //   {
      //     "id": "string_unica_do_item",
      //     "time": "09:00",
      //     "name": "Nome da Atividade",
      //     "description": "Descrição detalhada da atividade.",
      //     "checked": false
      //   },
      //   ... outros itens
      // ]
      // ---------------------------------------------------
      final url = Uri.parse(
        'https://sua-api.com.br/activities?userId=$_userId',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        setState(() {
          activityItems = jsonList
              .map((json) => ActivityItem.fromJson(json))
              .toList();
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Falha ao carregar atividades: ${response.statusCode}.';
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

  /// Envia a atualização do status de uma atividade para a API.
  Future<void> _updateActivityItemStatus(String id, bool newStatus) async {
    if (_userId == null) return;

    try {
      // --- CONTRATO DE DADOS: ATUALIZAR ATIVIDADE (PUT ou PATCH) ---
      // 1. ENDPOINT: A URL para atualizar uma atividade específica.
      //    A API deve identificar o item pelo 'id' passado na URL
      //    (ex: /activities/id_da_atividade).
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
      final url = Uri.parse('https://sua-api.com.br/activities/$id');

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
          'Status do item $id (Atividade) atualizado com sucesso para $newStatus',
        );
      } else {
        throw Exception('Falha ao atualizar status na API');
      }
    } catch (e) {
      // Reverte a mudança na UI em caso de falha
      setState(() {
        final itemIndex = activityItems.indexWhere((item) => item.id == id);
        if (itemIndex != -1) {
          activityItems[itemIndex].checked = !newStatus;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao salvar alteração. Tente novamente.'),
        ),
      );
      print('Erro ao atualizar status do item $id (Atividade): $e');
    }
  }

  void _showActivityInfo(
    BuildContext context,
    String activityName,
    String activityInfo,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Informações sobre:\n$activityName',
            style: _popupTextStyle.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: SingleChildScrollView(
            child: Text(
              activityInfo,
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
                style: _popupTextStyle.copyWith(color: Colors.orange),
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
                      text: 'Como estão suas ',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      children: [
                        TextSpan(
                          text: 'Atividades',
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: '?',
                          style: TextStyle(
                            color: Colors.orange,
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
                          'Atividade',
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
                onPressed: _fetchActivityItems,
                child: const Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
      );
    }
    if (activityItems.isEmpty) {
      return const Center(
        child: Text(
          'Nenhuma atividade encontrada.',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 120),
      itemCount: activityItems.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final item = activityItems[index];
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                setState(() => item.checked = !item.checked);
                _updateActivityItemStatus(item.id, item.checked);
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
                item.activity,
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
                    _showActivityInfo(context, item.activity, item.info),
              ),
            ),
          ],
        );
      },
    );
  }
}
