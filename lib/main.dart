import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_list_app/app/app.dart';
import "package:timezone/data/latest.dart" as tz;
import 'package:todo_list_app/notification/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  await NotificationService().initialize();

  runApp(const ProviderScope(child: FlutterRiverpodTodoApp()));
}
