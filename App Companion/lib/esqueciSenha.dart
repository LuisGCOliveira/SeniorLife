import 'package:flutter/material.dart';

class TelaRecuperarSenha extends StatelessWidget {
  const TelaRecuperarSenha({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Color(0xFF7AC77E)),
            shape: MaterialStateProperty.all(CircleBorder()),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(''),
        titleTextStyle: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Container(
            constraints: const BoxConstraints.expand(),
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/imagens/backgroundSenior.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(child: _caixaRecuperarSenha()),
        ],
      ),
    );
  }

  Widget _caixaRecuperarSenha() {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6FF),
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(2, 4)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Recuperação de Senha',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Campo E-mail
          const _CampoTexto(label: 'Nova senha:', hint: ''),
          const SizedBox(height: 20),

          // Campo código
          const _CampoTexto(label: 'Confirmar senha:', hint: ''),
          const SizedBox(height: 30),

          // Botão Continuar
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7AC77E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            ),
            child: const Text(
              'Continuar',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class _CampoTexto extends StatelessWidget {
  final String label;
  final String hint;

  const _CampoTexto({super.key, required this.label, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.black, fontSize: 16)),
        const SizedBox(height: 5),
        SizedBox(
          height: 40,
          child: TextField(
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFFFFAFA),
              hintText: hint,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Color(0xFF31A2C6)),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Color(0xFF31A2C6),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}
