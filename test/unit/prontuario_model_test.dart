import 'package:flutter_test/flutter_test.dart';
import 'package:prontuario_app/models/prontuario.dart';

void main() {
  group('Prontuario Model', () {
    test('TU-02: Deve converter Prontuario para Map corretamente', () {
      // Arrange
      final prontuario = Prontuario(
        paciente: 'João Silva',
        descricao: 'Consulta de rotina',
        data: DateTime(2024, 1, 15, 10, 30),
      );

      // Act
      final map = prontuario.toMap();

      // Assert
      expect(map['paciente'], equals('João Silva'));
      expect(map['descricao'], equals('Consulta de rotina'));
      expect(map['data'], equals('2024-01-15T10:30:00.000'));
    });

    test('Deve criar Prontuario a partir de Map', () {
      // Arrange
      final map = {
        'paciente': 'Maria Santos',
        'descricao': 'Exame médico',
        'data': '2024-01-15T14:30:00.000',
      };

      // Act
      final prontuario = Prontuario.fromMap('123', map);

      // Assert
      expect(prontuario.id, equals('123'));
      expect(prontuario.paciente, equals('Maria Santos'));
      expect(prontuario.descricao, equals('Exame médico'));
      expect(prontuario.data, equals(DateTime(2024, 1, 15, 14, 30)));
    });

    test('Deve criar cópia do Prontuario com copyWith', () {
      // Arrange
      final original = Prontuario(
        id: '1',
        paciente: 'João Silva',
        descricao: 'Consulta inicial',
        data: DateTime(2024, 1, 15),
      );

      // Act
      final copia = original.copyWith(
        paciente: 'João Silva Atualizado',
        descricao: 'Consulta de retorno',
      );

      // Assert
      expect(copia.id, equals('1'));
      expect(copia.paciente, equals('João Silva Atualizado'));
      expect(copia.descricao, equals('Consulta de retorno'));
      expect(copia.data, equals(DateTime(2024, 1, 15)));
    });

    test('Deve manter dados originais quando copyWith com null', () {
      // Arrange
      final original = Prontuario(
        id: '1',
        paciente: 'João Silva',
        descricao: 'Consulta inicial',
        data: DateTime(2024, 1, 15),
      );

      // Act
      final copia = original.copyWith();

      // Assert
      expect(copia.id, equals('1'));
      expect(copia.paciente, equals('João Silva'));
      expect(copia.descricao, equals('Consulta inicial'));
      expect(copia.data, equals(DateTime(2024, 1, 15)));
    });

    test('Deve criar Prontuario com id null quando não fornecido', () {
      // Arrange & Act
      final prontuario = Prontuario(
        paciente: 'Paciente Teste',
        descricao: 'Descrição Teste',
        data: DateTime.now(),
      );

      // Assert
      expect(prontuario.id, isNull);
      expect(prontuario.paciente, equals('Paciente Teste'));
      expect(prontuario.descricao, equals('Descrição Teste'));
    });
  });
}