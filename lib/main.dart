import 'package:flutter/material.dart';
import 'package:pem/controllers/notification_service.dart';
import 'package:pem/main_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.init();
  runApp(const MainApp());
}
