import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

// Configuração global para testes
void setupFirebaseTest() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    
    // Configurar Firebase para testes
    try {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "test-api-key",
          appId: "test-app-id", 
          messagingSenderId: "test-sender-id",
          projectId: "test-project-id",
        ),
      );
    } catch (e) {
      print('Firebase já inicializado ou erro na inicialização: $e');
    }
  });
}