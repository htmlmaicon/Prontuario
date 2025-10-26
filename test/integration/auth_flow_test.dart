import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:prontuario_app/main.dart';
import 'package:prontuario_app/screens/login_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Auth Flow Integration Test', () {
    testWidgets('TI-01: Deve carregar a tela de login inicial', (WidgetTester tester) async {
      // Arrange & Act: Iniciar o app
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle();

      // Assert: Verificar que a tela de login foi carregada
      expect(find.text('Prontuário Eletrônico'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
    });

    testWidgets('TI-02: Campos de email e senha estão presentes', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byKey(Key('emailField')), findsOneWidget);
      expect(find.byKey(Key('passwordField')), findsOneWidget);
      expect(find.text('Entrar'), findsOneWidget);
    });

    testWidgets('TI-03: Validação mostra erro quando campos estão vazios', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle();

      // Act: Clicar em entrar sem preencher campos
      await tester.tap(find.text('Entrar'));
      await tester.pump(); // process validation

      // Assert: Verifica mensagens de erro
      expect(find.text('Informe o email'), findsOneWidget);
      expect(find.text('Senha deve ter pelo menos 10 caracteres'), findsOneWidget);
    });

    testWidgets('TI-04: Alternar entre Login e Registrar', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle();

      // Verifica modo login inicial
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Entrar'), findsOneWidget);

      // Act: Alternar para registro
      await tester.tap(find.text('Criar uma conta'));
      await tester.pumpAndSettle();

      // Assert: Verifica modo registro
      expect(find.text('Registrar'), findsNWidgets(2)); // Título e botão
      expect(find.text('Já tenho uma conta'), findsOneWidget);

      // Act: Voltar para login
      await tester.tap(find.text('Já tenho uma conta'));
      await tester.pumpAndSettle();

      // Assert: Verifica modo login novamente
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Entrar'), findsOneWidget);
    });

    testWidgets('TI-05: Preencher campos de email e senha', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle();

      // Act: Preencher campos
      await tester.enterText(find.byKey(Key('emailField')), 'teste@example.com');
      await tester.enterText(find.byKey(Key('passwordField')), 'senhateste123');

      // Assert: Verifica se os campos foram preenchidos
      expect(find.text('teste@example.com'), findsOneWidget);
      expect(find.text('senhateste123'), findsOneWidget);
    });

    testWidgets('TI-06: Validação de senha curta', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle();

      // Act: Preencher com senha curta
      await tester.enterText(find.byKey(Key('emailField')), 'user@example.com');
      await tester.enterText(find.byKey(Key('passwordField')), 'short123'); // 8 chars < 10
      await tester.tap(find.text('Entrar'));
      await tester.pump();

      // Assert: Verifica mensagem de erro
      expect(find.text('Senha deve ter pelo menos 10 caracteres'), findsOneWidget);
    });
  });
}