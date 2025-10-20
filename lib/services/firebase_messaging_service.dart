import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirebaseMessagingService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Solicitar permissões
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('Usuário concedeu permissão para notificações');
    }

    // Configurar notificações locais
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
    
    await _localNotifications.initialize(initializationSettings);

    // Configurar handlers para mensagens
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
    
    // Obter token
    String? token = await _firebaseMessaging.getToken();
    print('FCM Token: $token');
  }

  void _handleForegroundMessage(RemoteMessage message) {
    print('Notificação recebida em foreground: ${message.notification?.title}');
    
    _showLocalNotification(
      message.notification?.title ?? 'Novo Prontuário',
      message.notification?.body ?? 'Há uma nova atualização no seu prontuário',
    );
  }

  void _handleBackgroundMessage(RemoteMessage message) {
    print('Notificação recebida em background: ${message.notification?.title}');
  }

  Future<void> _showLocalNotification(String title, String body) async {
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
    
    await _localNotifications.show(
      0,
      title,
      body,
      details,
    );
  }

  Future<void> showProntuarioNotification(String paciente, String acao) async {
    await _showLocalNotification(
      'Prontuário $acao',
      'Prontuário do paciente $paciente $acao com sucesso',
    );
  }
}