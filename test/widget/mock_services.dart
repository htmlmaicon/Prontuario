import 'package:mockito/annotations.dart';
import 'package:prontuario_app/services/auth_service.dart';
import 'package:prontuario_app/services/firestore_service.dart';

// Gerar mocks: flutter pub run build_runner build
@GenerateMocks([AuthService, FirestoreService])
void main() {}