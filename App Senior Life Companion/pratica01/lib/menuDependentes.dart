import 'package:flutter/material.dart';
import 'menuAddDependente.dart';

void main() {
  runApp(const TelaAdicionarDependente());
}

class TelaAdicionarDependente extends StatelessWidget {
  const TelaAdicionarDependente({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: _barraSuperior(context),
        body: Column(
          children: [
            const SizedBox(height: 650),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TelaCadastroDependente(),
                    ),
                  );
                },
                icon: const Icon(Icons.add, color: Colors.green),
                label: const Text(
                  'Adicionar dependente',
                  style: TextStyle(color: Colors.black),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Colors.green),
                  elevation: 3,
                  shadowColor: Colors.black26,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                ),
              ),
            ),
            const Spacer(),
            _rodapeInferior(context),
          ],
        ),
      ),
    );
  }

  // Barra superior da tela
  PreferredSizeWidget _barraSuperior(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF31A2C6),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset('assets/imagens/logo.png', height: 50),
          const Icon(Icons.person, color: Colors.white, size: 40),
        ],
      ),
    );
  }

  // Rodapé inferior com ícones
  Widget _rodapeInferior(BuildContext context) {
    return Container(
      height: 100,
      color: const Color(0xFF31A2C6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Botão de engrenagem com animação
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              showGeneralDialog(
                context: context,
                barrierDismissible: true,
                barrierLabel: 'Configurações',
                transitionDuration: const Duration(milliseconds: 300),
                pageBuilder: (context, anim1, anim2) {
                  return const SizedBox.shrink();
                },
                transitionBuilder: (context, anim1, anim2, child) {
                  return Transform.scale(
                    scale: anim1.value,
                    child: Opacity(
                      opacity: anim1.value,
                      child: Center(
                        child: Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Container(
                            width: 270,
                            padding: const EdgeInsets.symmetric(
                              vertical: 30,
                              horizontal: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.lightBlue,
                                width: 3,
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _botaoMenu('Perfil'),
                                const Divider(thickness: 2),
                                _botaoMenu('Lembretes'),
                                const Divider(thickness: 2),
                                _botaoMenu('Saúde'),
                                const Divider(thickness: 2),
                                _botaoMenu('Notificações'),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
          const Icon(Icons.person, color: Colors.white),
          const Icon(Icons.calendar_today, color: Colors.white),
        ],
      ),
    );
  }

  // Botão do menu animado
  static Widget _botaoMenu(String texto) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Center(
        child: Text(
          texto,
          style: const TextStyle(
            color: Color(0xFF2B5C6B),
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
