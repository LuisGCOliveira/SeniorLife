import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FoodItem {
  final String id;
  final String time;
  final String food;
  final String info;
  bool checked;

  FoodItem({
    required this.id,
    required this.time,
    required this.food,
    required this.info,
    this.checked = false,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'] as String,
      time: json['time'] as String,
      food: json['name'] as String,
      info: json['description'] as String,
      checked: json['checked'] as bool? ?? false,
    );
  }
}

class FoodPage extends StatefulWidget {
  const FoodPage({super.key});

  @override
  State<FoodPage> createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage> {
  String? _userId;
  List<FoodItem> foodItems = [];
  bool isLoading = true;
  String? error;

  final TextStyle _popupTextStyle = const TextStyle(fontSize: 22);

  @override
  void initState() {
    super.initState();
    _loadUserIdAndFetchItems();
  }

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
    _fetchFoodItems();
  }

  /// Busca a lista de alimentos do usuário logado na API.
  Future<void> _fetchFoodItems() async {
    if (_userId == null) return;

    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      // --- CONTRATO DE DADOS: BUSCAR ITENS (GET) ---
      // 1. ENDPOINT: A URL para buscar os alimentos do usuário.
      //    A API deve ser capaz de filtrar os resultados pelo 'userId'
      //    enviado como um "query parameter" (ex: /fooditems?userId=...).
      //    [!] SUBSTITUA A URL ABAIXO PELA SUA URL REAL.
      //
      // 2. RESPOSTA (JSON): Se a busca for bem-sucedida (statusCode 200),
      //    a API deve retornar uma LISTA de objetos, onde cada objeto
      //    tem o seguinte formato:
      //
      // [
      //   {
      //     "id": "string_unica_do_item",
      //     "time": "08:30",
      //     "name": "Nome do Alimento",
      //     "description": "Descrição detalhada do alimento.",
      //     "checked": false
      //   },
      //   ... outros itens
      // ]
      // ---------------------------------------------------
      final url = Uri.parse('https://sua-api.com.br/fooditems?userId=$_userId');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        setState(() {
          foodItems = jsonList.map((json) => FoodItem.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Falha ao carregar alimentos: ${response.statusCode}.';
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
  Future<void> _updateFoodItemStatus(String id, bool newStatus) async {
    if (_userId == null) return;

    try {
      // --- CONTRATO DE DADOS: ATUALIZAR ITEM (PUT ou PATCH) ---
      // 1. ENDPOINT: A URL para atualizar um item específico.
      //    A API deve identificar o item pelo 'id' passado na URL
      //    (ex: /fooditems/id_do_item).
      //    [!] SUBSTITUA A URL ABAIXO PELA SUA URL REAL.
      //
      // 2. REQUISIÇÃO (JSON): O Flutter envia um JSON no corpo ('body')
      //    da requisição com os dados a serem atualizados. Para autorização,
      //    também enviamos o 'userId'. Formato:
      //
      // {
      //   "checked": true,  // ou false
      //   "userId": "id_do_usuario_logado"
      // }
      //
      // 3. RESPOSTA: A API deve apenas confirmar o sucesso com um
      //    statusCode 200. O corpo da resposta pode ser vazio.
      // ---------------------------------------------------
      final url = Uri.parse('https://sua-api.com.br/fooditems/$id');

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
          'Status do item $id (Alimento) atualizado com sucesso para $newStatus',
        );
      } else {
        throw Exception('Falha ao atualizar status na API');
      }
    } catch (e) {
      // Reverte a mudança na UI em caso de falha
      setState(() {
        final itemIndex = foodItems.indexWhere((item) => item.id == id);
        if (itemIndex != -1) {
          foodItems[itemIndex].checked = !newStatus;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao salvar alteração. Tente novamente.'),
        ),
      );
      print('Erro ao atualizar status do item $id (Alimento): $e');
    }
  }

  void _showFoodInfo(BuildContext context, String foodName, String foodInfo) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Informações sobre:\n$foodName',
            style: _popupTextStyle.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: SingleChildScrollView(
            child: Text(
              foodInfo,
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
                style: _popupTextStyle.copyWith(color: Colors.green),
              ),
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
                          text: 'Alimentação',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: '?',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Cabeçalho da Lista
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const SizedBox(width: 40 + 16), // Espaço para o checkbox
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
                          'Alimento',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const SizedBox(width: 36), // Espaço para o ícone de info
                    ],
                  ),
                ),
                const Divider(thickness: 1),
                // Corpo da Lista
                Expanded(child: _buildBody()),
              ],
            ),
          ),
          // Footer
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

  // Widget auxiliar para construir o corpo da tela (loading, erro, lista)
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
                onPressed: _fetchFoodItems,
                child: const Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
      );
    }

    if (foodItems.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum plano alimentar encontrado.',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 120),
      itemCount: foodItems.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final item = foodItems[index];
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                setState(() => item.checked = !item.checked);
                _updateFoodItemStatus(item.id, item.checked);
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
                item.food,
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
                onPressed: () => _showFoodInfo(context, item.food, item.info),
              ),
            ),
          ],
        );
      },
    );
  }
}
