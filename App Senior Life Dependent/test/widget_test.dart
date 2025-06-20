// test/widget_test.dart (VERSÃO CORRIGIDA)

import 'package:flutter_test/flutter_test.dart';
import 'package:meu_app/main.dart'; // Certifique-se que o caminho está correto

void main() {
  testWidgets('Smoke test inicial', (WidgetTester tester) async {
    // Mudei o nome do teste para algo mais genérico
    // Build our app and trigger a frame.

    // CORRIGIDO AQUI:
    await tester.pumpWidget(const SeniorLifeApp());

    // Como seu app agora começa com a AuthCheckPage e vai para o Login,
    // um bom teste inicial é verificar se o botão "Entrar" existe.
    // O teste de contador (0 e 1) não se aplica mais.

    // Aguarda um pouco para a navegação da AuthCheckPage acontecer.
    await tester.pumpAndSettle();

    // Verifica se o botão "Entrar" está na tela de login.
    expect(find.text('Entrar'), findsOneWidget);
  });
}
