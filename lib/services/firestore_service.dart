import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/prontuario.dart';
import 'notification_service.dart'; // ADICIONE ESTA LINHA

class FirestoreService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get _prontuariosCollection {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return FirebaseFirestore.instance.collection('empty');
    }
    return FirebaseFirestore.instance
        .collection('usuarios')
        .doc(userId)
        .collection('prontuarios');
  }

  Future<void> adicionarProntuario(Prontuario prontuario) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    
    await _prontuariosCollection.add(prontuario.toMap());
    
    // ENVIAR NOTIFICAÇÃO - ADICIONE ESTA LINHA
    await NotificationService().showProntuarioNotification(prontuario.paciente, 'criado');
  }

  Future<void> atualizarProntuario(Prontuario prontuario) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null || prontuario.id == null) return;
    
    await _prontuariosCollection
        .doc(prontuario.id)
        .update(prontuario.toMap());
    
    // ENVIAR NOTIFICAÇÃO - ADICIONE ESTA LINHA
    await NotificationService().showProntuarioNotification(prontuario.paciente, 'atualizado');
  }

  Future<void> deletarProntuario(String id) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    
    await _prontuariosCollection.doc(id).delete();
    
    // ENVIAR NOTIFICAÇÃO - ADICIONE ESTA LINHA
    await NotificationService().showProntuarioNotification('', 'excluído');
  }

  Stream<List<Prontuario>> getProntuarios() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return Stream.value([]);
    }
    
    return _prontuariosCollection
        .orderBy('data', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => Prontuario.fromMap(
                  doc.id, 
                  doc.data() as Map<String, dynamic>,
                ),
              )
              .toList(),
        );
  }

  Future<Prontuario?> getProntuarioById(String id) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return null;
    
    try {
      final doc = await _prontuariosCollection.doc(id).get();
      if (doc.exists) {
        return Prontuario.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Erro ao buscar prontuário: $e');
      return null;
    }
  }
}