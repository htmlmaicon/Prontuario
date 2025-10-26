import 'package:flutter_test/flutter_test.dart';
import 'package:prontuario_app/services/auth_service.dart';
import '../test_config.dart';

void main() {
  setupFirebaseTest();

  group('AuthService - Validação de Email', () {
    late AuthService authService;

    setUp(() {
      authService = AuthService();
    });

    test('TU-01: Deve retornar false para e-mail inválido', () {
      // Arrange & Act
      final isValid = authService.validateEmail("invalido@");
      
      // Assert
      expect(isValid, isFalse);
    });

    test('TU-02: Deve retornar true para e-mail válido', () {
      // Arrange & Act
      final isValid = authService.validateEmail("usuario@valido.com");
      
      // Assert
      expect(isValid, isTrue);
    });

    test('Deve retornar false para e-mail sem domínio', () {
      // Arrange & Act
      final isValid = authService.validateEmail("usuario@");
      
      // Assert
      expect(isValid, isFalse);
    });

    test('Deve retornar false para e-mail sem @', () {
      // Arrange & Act
      final isValid = authService.validateEmail("usuariovalido.com");
      
      // Assert
      expect(isValid, isFalse);
    });

    test('Deve retornar false para e-mail vazio', () {
      // Arrange & Act
      final isValid = authService.validateEmail("");
      
      // Assert
      expect(isValid, isFalse);
    });

    test('Deve retornar false para e-mail com múltiplos @', () {
      // Arrange & Act
      final isValid = authService.validateEmail("user@@domain.com");
      
      // Assert
      expect(isValid, isFalse);
    });
  });
}