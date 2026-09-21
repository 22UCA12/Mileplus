import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
    // =========================================================
    // FIREBASE MESSAGING
    // =========================================================

    static final FirebaseMessaging _firebaseMessaging =
        FirebaseMessaging.instance;

    // =========================================================
    // LOCAL NOTIFICATIONS
    // =========================================================

    static final FlutterLocalNotificationsPlugin _localNotifications =
    FlutterLocalNotificationsPlugin();

    // =========================================================
    // INITIALIZE NOTIFICATIONS
    // =========================================================

    static Future<void> initialize() async {
        // Android notification settings
        const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

        const InitializationSettings settings = InitializationSettings(
            android: androidSettings,
        );

        // Initialize local notifications
        await _localNotifications.initialize(
            settings,
            onDidReceiveNotificationResponse: (NotificationResponse response) {
                print('Local notification clicked');
                print('Payload: ${response.payload}');
            },
        );

        // Android 13+ notification permission
        await _localNotifications
            .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission();

        // Firebase notification permission
        final NotificationSettings permission =
        await _firebaseMessaging.requestPermission(
            alert: true,
            badge: true,
            sound: true,
        );

        print('Notification permission: ${permission.authorizationStatus}');

        // Get FCM token
        final String? token = await _firebaseMessaging.getToken();

        print('====================================');
        print('MILEPLUS FCM TOKEN');
        print(token);
        print('====================================');

        // =======================================================
        // FOREGROUND PUSH NOTIFICATION
        // =======================================================

        FirebaseMessaging.onMessage.listen(
                (RemoteMessage message) {
                print('====================================');
                print('Foreground notification received');
                print('Title: ${message.notification?.title}');
                print('Body: ${message.notification?.body}');
                print('Data: ${message.data}');
                print('====================================');

                final String title =
                    message.notification?.title ?? 'MilePlus';

                final String body =
                    message.notification?.body ?? 'You have a new notification';

                showNotification(
                    title: title,
                    body: body,
                );
            },
        );

        // =======================================================
        // NOTIFICATION CLICKED
        // =======================================================

        FirebaseMessaging.onMessageOpenedApp.listen(
                (RemoteMessage message) {
                print('Notification clicked');
                print('Notification data: ${message.data}');
            },
        );

        // =======================================================
        // APP OPENED FROM TERMINATED STATE
        // =======================================================

        final RemoteMessage? initialMessage =
        await _firebaseMessaging.getInitialMessage();

        if (initialMessage != null) {
            print('App opened from notification');
            print('Notification data: ${initialMessage.data}');
        }
    }

    // =========================================================
    // SHOW PUSH NOTIFICATION
    // =========================================================

    static Future<void> showNotification({
        required String title,
        required String body,
    }) async {
        const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
            'mileplus_trip_channel',
            'MilePlus Trip Notifications',
            channelDescription: 'Notifications for allocated trips',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
        );

        const NotificationDetails details = NotificationDetails(
            android: androidDetails,
        );

        await _localNotifications.show(
            DateTime.now().millisecondsSinceEpoch % 100000,
            title,
            body,
            details,
        );
    }

    // =========================================================
    // LICENSE EXPIRED NOTIFICATION
    // =========================================================

    static Future<void> showExpiredNotification(
        String licenseNumber,
        ) async {
        const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
            'license_expiry_channel',
            'License Expiry',
            channelDescription:
            'Driver license expiry notifications',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
        );

        const NotificationDetails details = NotificationDetails(
            android: androidDetails,
        );

        await _localNotifications.show(
            1001,
            'License Expired',
            'License $licenseNumber has expired.',
            details,
        );
    }
    static Future<void> cancelExpiryNotification() async {
        await _localNotifications.cancel(1001);

        print('License expiry notification cancelled');
    }
}