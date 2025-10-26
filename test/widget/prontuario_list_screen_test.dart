import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:prontuario_app/screens/prontuario_list_screen.dart';
import 'package:prontuario_app/services/firestore_service.dart';
import 'package:prontuario_app/services/auth_service.dart';
import 'package:prontuario_app/models/prontuario.dart';

class MockFirestoreService extends Mock implements FirestoreService {}
class MockAuthService extends Mock implements AuthService {}

void main() {
  group('ProntuarioListScreen Widget Tests', () {
    late MockFirestoreService mockFirestoreService;
    late MockAuthService mockAuthService;

    setUp(() {
      mockFirestoreService = MockFirestoreService();
      mockAuthService = MockAuthService();
    });

    testWidgets('TW-02: Deve exibir lista de prontuários', (WidgetTester tester) async {
      // Arrange
      final prontuarios = [
        Prontuario(
          id: '1',
          paciente: 'João Silva',
          descricao: 'Consulta cardiológica',
          data: DateTime(2024, 1, 15, 10, 30),
        ),
        Prontuario(
          id: '2',
          paciente: 'Maria Santos',
          descricao: 'Exame de sangue',
          data: DateTime(2024, 1, 14, 14, 15),
        ),
      ];

      when(mockFirestoreService.getProntuarios())
          .thenAnswer((_) => Stream.value(prontuarios));

      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              Provider<FirestoreService>.value(value: mockFirestoreService),
              Provider<AuthService>.value(value: mockAuthService),
            ],
            child: ProntuarioListScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert: Verifica se os prontuários são exibidos
      expect(find.text('João Silva'), findsOneWidget);
      expect(find.text('Maria Santos'), findsOneWidget);
      expect(find.text('Consulta cardiológica'), findsOneWidget);
      expect(find.text('Exame de sangue'), findsOneWidget);
    });

    testWidgets('Deve exibir mensagem quando não há prontuários', (WidgetTester tester) async {
      // Arrange
      when(mockFirestoreService.getProntuarios())
          .thenAnswer((_) => Stream.value([]));

      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              Provider<FirestoreService>.value(value: mockFirestoreService),
              Provider<AuthService>.value(value: mockAuthService),
            ],
            child: ProntuarioListScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert: Verifica mensagem de lista vazia
      expect(find.text('Nenhum prontuário cadastrado'), findsOneWidget);
    });

    testWidgets('Deve exibir barra de pesquisa', (WidgetTester tester) async {
      // Arrange
      when(mockFirestoreService.getProntuarios())
          .thenAnswer((_) => Stream.value([]));

      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              Provider<FirestoreService>.value(value: mockFirestoreService),
              Provider<AuthService>.value(value: mockAuthService),
            ],
            child: ProntuarioListScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert: Verifica se a barra de pesquisa está presente
      expect(find.text('Pesquisar paciente'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });
  });
}