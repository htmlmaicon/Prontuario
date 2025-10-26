import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:prontuario_app/screens/login_screen.dart';
import 'package:prontuario_app/services/auth_service.dart';

class MockAuthService extends Mock implements AuthService {}

void main() {
  group('LoginScreen Widget Tests', () {
    late MockAuthService mockAuthService;

    setUp(() {
      mockAuthService = MockAuthService();
    });

    testWidgets('TW-01: Deve exibir erro ao submeter campos vazios', (WidgetTester tester) async {
      // Arrange
      when(mockAuthService.user).thenAnswer((_) => Stream.value(null));

      await tester.pumpWidget(
        MaterialApp(
          home: Provider<AuthService>.value(
            value: mockAuthService,
            child: LoginScreen(),
          ),
        ),
      );

      // Act: Tocar no botão "Entrar" sem preencher campos
      await tester.tap(find.text('Entrar'));
      await tester.pump(); // Re-renderiza para mostrar erros

      // Assert: Verifica as mensagens de erro
      expect(find.text('Informe o email'), findsOneWidget);
      expect(find.text('Senha deve ter pelo menos 10 caracteres'), findsOneWidget);
    });

    testWidgets('Deve alternar entre login e registro', (WidgetTester tester) async {
      // Arrange
      when(mockAuthService.user).thenAnswer((_) => Stream.value(null));

      await tester.pumpWidget(
        MaterialApp(
          home: Provider<AuthService>.value(
            value: mockAuthService,
            child: LoginScreen(),
          ),
        ),
      );

      // Verifica que está em modo login inicialmente
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Entrar'), findsOneWidget);

      // Act: Clicar para alternar para registro
      await tester.tap(find.text('Criar uma conta'));
      await tester.pump();

      // Assert: Verifica que mudou para modo registro
      expect(find.text('Registrar'), findsOneWidget);
      expect(find.text('Já tenho uma conta'), findsOneWidget);
    });

    testWidgets('Deve preencher campos de email e senha', (WidgetTester tester) async {
      // Arrange
      when(mockAuthService.user).thenAnswer((_) => Stream.value(null));

      await tester.pumpWidget(
        MaterialApp(
          home: Provider<AuthService>.value(
            value: mockAuthService,
            child: LoginScreen(),
          ),
        ),
      );

      // Act: Preencher campos
      await tester.enterText(find.byKey(Key('emailField')), 'teste@example.com');
      await tester.enterText(find.byKey(Key('passwordField')), 'senhateste123');

      // Assert: Verifica se os campos foram preenchidos
      expect(find.text('teste@example.com'), findsOneWidget);
      expect(find.text('senhateste123'), findsOneWidget);
    });
  });
}