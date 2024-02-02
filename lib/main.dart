import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'firebase_options.dart';
import 'login_screen.dart';
import 'order_screen.dart';
import 'restaurant_dash.dart';
import 'user_type_selection.dart';
import 'signup_screen.dart';
import 'notification_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  String app_icon='assets/login-icon/food_delivery_logo.png';
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await AwesomeNotifications().initialize('resource://drawable/ic_stat_food_delivery_logo_recovered',
      [
        NotificationChannel(
          channelGroupKey: "basic_channel_group",
            channelKey: "basic_channel",
            channelName: "basic_notifications",
            channelDescription: "basic channel",
          importance: NotificationImportance.High,
          ledColor: Colors.white,
          channelShowBadge: true,

        )
      ],

    channelGroups: [
      NotificationChannelGroup(channelGroupKey: "basic_channel_group", channelGroupName: "basic_group")
    ]
  );
  bool isAllowedToSendNotification=await AwesomeNotifications().isNotificationAllowed();
  if(!isAllowedToSendNotification){
    AwesomeNotifications().requestPermissionToSendNotifications();
  }
  runApp(MyApp());
}
/*
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}
*/

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    // TODO: implement initState
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: NotificationController.onActionReceivedMethod,
      onNotificationCreatedMethod: NotificationController.onNotificationCreatedMethod,
      onNotificationDisplayedMethod: NotificationController.onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: NotificationController.onDismissActionReceivedMethod,
    );
    super.initState();
  }
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'eCrunchies',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => UserTypeSelection(),
        '/home': (context) => OrderScreen(),
        '/restaurantDashboard': (context) => RestaurantDashboard(),
        '/orderScreen': (context) => OrderScreen(),
        '/login': (context) => LoginScreen(userType: ''),
        '/signup': (context) => SignupScreen(userType: ''),
      },
    );
  }
}

