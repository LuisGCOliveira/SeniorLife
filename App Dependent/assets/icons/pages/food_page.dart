import 'package:flutter/material.dart';

 class FoodPage extends StatefulWidget {
  const FoodPage({super.key});

  @override
  State<FoodPage> createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage> {
  final List<Map<String, dynamic>> foodItems = [
    {'time': '08:30', 'food': 'Café e ovos', 'checked': false},
    {'time': '10:00', 'food': 'Fruta', 'checked': false},
    {'time': '12:30', 'food': 'Almoço proteico', 'checked': false},
    {'time': '15:15', 'food': 'Leite com Granola', 'checked': false},
    {'time': '15:15', 'food': 'Leite com Granola', 'checked': false},
    {'time': '15:15', 'food': 'Leite com Granola', 'checked': false},
    {'time': '15:15', 'food': 'Leite com Granola', 'checked': false},
    {'time': '15:15', 'food': 'Leite com Granola', 'checked': false},
    {'time': '15:15', 'food': 'Leite com Granola', 'checked': false},
    {'time': '15:15', 'food': 'Leite com Granola', 'checked': false},
    {'time': '15:15', 'food': 'Leite com Granola', 'checked': false},
    {'time': '15:15', 'food': 'Leite com Granola', 'checked': false},
    {'time': '15:15', 'food': 'Leite com Granola', 'checked': false},
    {'time': '15:15', 'food': 'Leite com Granola', 'checked': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
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
                        text: '!!',
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
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(width: 60, child: Text('')),
                    Text(
                      'Horário',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Alimento',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 40),
                  ],
                ),
              ),
              const Divider(thickness: 1),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: foodItems.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final item = foodItems.elementAt(index);

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              item['checked'] = !item['checked'];
                            });
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              border: Border.all(width: 2),
                            ),
                            child: item['checked']
                                ? const Icon(Icons.check, color: Colors.green)
                                : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        SizedBox(
                          width: 60,
                          child: Text(
                            item['time'],
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            item['food'],
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.lightBlue,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.info, color: Colors.white),
                            onPressed: () {
                              // Futuro: abrir popup com info do alimento
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),

          // Rodapé com imagem e botão
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
                  bottom: 10,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Image.asset(
                          'assets/icons/home.png',
                          fit: BoxFit.contain,
                        ),
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
}
