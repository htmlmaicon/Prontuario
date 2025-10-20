import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  BuildContext? _context;

  // ADICIONE ESTE MÉTODO PARA DEFINIR O CONTEXTO
  void setContext(BuildContext context) {
    _context = context;
  }

  Future<void> initialize() async {
    print('🔔 Inicializando serviço de notificações...');
    
    if (kIsWeb) {
      print('🌐 Modo Web detectado - Notificações adaptadas para browser');
      return;
    }
    
    const AndroidInitializationSettings androidSettings = 
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings iosSettings = 
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );
    
    const InitializationSettings initializationSettings = 
        InitializationSettings(
          android: androidSettings,
          iOS: iosSettings,
        );
    
    try {
      await _localNotifications.initialize(initializationSettings);
      print('✅ Notificações inicializadas com sucesso');
    } catch (e) {
      print('❌ Erro ao inicializar notificações: $e');
    }

    // Criar canal para Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'prontuario_channel',
      'Notificações de Prontuário',
      description: 'Canal para notificações do app Prontuário Eletrônico',
      importance: Importance.high,
    );
    
    try {
      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
      print('✅ Canal de notificação criado: prontuario_channel');
    } catch (e) {
      print('❌ Erro ao criar canal: $e');
    }
  }

  Future<void> showProntuarioNotification(String paciente, String acao) async {
    print('🔔 Tentando enviar notificação: $acao - Paciente: $paciente');
    
    if (kIsWeb) {
      // No navegador, usar SnackBar ou console
      print('📢 NOTIFICAÇÃO WEB: Prontuário $acao - Paciente: $paciente');
      
      // Mostrar SnackBar se tiver contexto
      if (_context != null && _context!.mounted) {
        ScaffoldMessenger.of(_context!).showSnackBar(
          SnackBar(
            content: Text('📋 Prontuário $acao: $paciente'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }
    
    // Código original para mobile
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'prontuario_channel',
      'Notificações de Prontuário',
      channelDescription: 'Canal para notificações do app Prontuário Eletrônico',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();
    
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    try {
      await _localNotifications.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        'Prontuário $acao',
        paciente.isEmpty 
            ? 'Prontuário $acao com sucesso'
            : 'Prontuário do paciente $paciente $acao com sucesso',
        details,
      );
      print('✅ Notificação enviada com sucesso!');
    } catch (e) {
      print('❌ Erro ao enviar notificação: $e');
    }
  }
}