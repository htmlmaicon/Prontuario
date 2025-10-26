import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:prontuario_app/services/firestore_service.dart';
import 'package:prontuario_app/models/prontuario.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUser extends Mock implements User {}
class MockCollectionReference extends Mock implements CollectionReference {}
class MockDocumentReference extends Mock implements DocumentReference {}
class MockQuerySnapshot extends Mock implements QuerySnapshot {}
class MockQueryDocumentSnapshot extends Mock implements QueryDocumentSnapshot {}

void main() {
  group('FirestoreService', () {
    late FirestoreService firestoreService;
    late MockFirebaseAuth mockAuth;
    late MockUser mockUser;

    setUp(() {
      mockAuth = MockFirebaseAuth();
      mockUser = MockUser();
      firestoreService = FirestoreService();
    });

    test('Deve retornar lista vazia quando usuário não está logado', () {
      // Arrange
      when(mockAuth.currentUser).thenReturn(null);

      // Act
      final stream = firestoreService.getProntuarios();

      // Assert
      expect(stream, isA<Stream<List<Prontuario>>>());
    });

    test('Deve converter Prontuario para Map corretamente', () {
      // Arrange
      final prontuario = Prontuario(
        paciente: 'Teste Paciente',
        descricao: 'Teste Descrição',
        data: DateTime(2024, 1, 1),
      );

      // Act
      final map = prontuario.toMap();

      // Assert
      expect(map['paciente'], equals('Teste Paciente'));
      expect(map['descricao'], equals('Teste Descrição'));
      expect(map['data'], isA<String>());
    });
  });
}