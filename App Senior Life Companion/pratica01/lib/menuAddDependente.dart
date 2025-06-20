import 'package:flutter/material.dart';

void main() {
  runApp(const TelaCadastroDependente());
}

class TelaCadastroDependente extends StatelessWidget {
  const TelaCadastroDependente({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: _barraSuperior(),
        body: Column(
          children: [
            Expanded(child: _conteudoFormulario()),
            _rodapeInferior(context),
          ],
        ),
      ),
    );
  }

  // Barra superior com logo e ícone de usuário
  PreferredSizeWidget _barraSuperior() {
    return AppBar(
      backgroundColor: const Color(0xFF31A2C6),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset('assets/imagens/logo.png', height: 40),
          const Icon(Icons.person, color: Colors.white, size: 30),
        ],
      ),
    );
  }

  // Conteúdo principal com formulário
  Widget _conteudoFormulario() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      child: Column(
        children: [
          // Ícone de editar
          const Icon(Icons.edit, color: Colors.green, size: 50),
          const SizedBox(height: 20),
          _campoTexto(label: 'Nome:'),
          const SizedBox(height: 10),
          _campoTexto(label: 'Idade:'),
          const SizedBox(height: 10),
          _campoTexto(label: 'Endereço:'),
          const SizedBox(height: 10),
          _campoTextoGrande(label: 'Restrições:'),
        ],
      ),
    );
  }

  // Campo de texto padrão
  Widget _campoTexto({required String label}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 5),
        TextField(
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Color(0xFF31A2C6)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(width: 2, color: Color(0xFF31A2C6)),
            ),
          ),
        ),
      ],
    );
  }

  // Campo de texto grande (para restrições)
  Widget _campoTextoGrande({required String label}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 5),
        TextField(
          maxLines: 5,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFFFFAFA),
            contentPadding: const EdgeInsets.all(12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Color(0xFF31A2C6)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(width: 2, color: Color(0xFF31A2C6)),
            ),
          ),
        ),
      ],
    );
  }

  // Rodapé com ícones e animação do menu
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
