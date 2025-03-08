import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:todo_list_app/config/routes/routes_location.dart';
import 'package:todo_list_app/data/models/task.dart';
import 'package:todo_list_app/notification/notification_service.dart';
import 'package:todo_list_app/providers/category_provider.dart';
import 'package:todo_list_app/providers/task/tasks_provider.dart';
import 'package:todo_list_app/screens/date_time.dart';
import 'package:todo_list_app/utils/app_alerts.dart';
import 'package:todo_list_app/utils/extensions.dart';
import 'package:todo_list_app/utils/helpers.dart';
import 'package:todo_list_app/widgets/categories_selection.dart';
import 'package:todo_list_app/widgets/common_text_field.dart';
import 'package:todo_list_app/widgets/display_white_text.dart';

class CreateTaskScreen extends ConsumerStatefulWidget {
  static CreateTaskScreen builder(BuildContext context, GoRouterState state) =>
      const CreateTaskScreen();
  const CreateTaskScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CreateTaskScreenState();
}

class _CreateTaskScreenState extends ConsumerState<CreateTaskScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  NotificationService _notificationService = NotificationService();
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  Future<void> _scheduleDateTime(String title, String note) async {
    final DateTime scheduledDate = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );
    if (scheduledDate.isBefore(DateTime.now())) {
      if (mounted) {
        AppAlerts.displaySnackbar(context, 'Please select a future date');
      }
      return;
    }

    await _notificationService.scheduleNotification(scheduledDate, title, note);
    if (mounted) {
      AppAlerts.displaySnackbar(context, 'Notification schudeled ');
    }
  }

  PermissionStatus _notificationStatus = PermissionStatus.denied;
  Future<void> _requestAndCheckNotificationPermission() async {
    var status = await Permission.notification.status;
    if (!status.isGranted) {
      status = await Permission.notification.request();
    }
    setState(() {
      _notificationStatus = status;
    });
    if (status.isDenied || status.isPermanentlyDenied) {
      _openAppSettings();
    }
  }

  Future<void> _openAppSettings() async {
    await AppSettings.openAppSettings(type: AppSettingsType.notification);
  }

  void updateDateTime(DateTime date, TimeOfDay time) async {
    setState(() {
      selectedDate = date;
      selectedTime = time;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _requestAndCheckNotificationPermission();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.primary,
        title: const DisplayWhiteText(text: 'Add New Task'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CommonTextField(
                hintText: 'Task Title',
                title: 'Task Title',
                controller: _titleController,
              ),
              const Gap(30),
              const CategoriesSelection(),
              const Gap(30),
              DateTimeSelector(
                selectedDate: selectedDate,
                selectedTime: selectedTime,
                onDateTimeChanged: updateDateTime,
              ),
              const Gap(30),
              CommonTextField(
                hintText: 'Notes',
                title: 'Notes',
                maxLines: 6,
                controller: _noteController,
              ),
              const Gap(30),
              ElevatedButton(
                onPressed: _createTask,
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: DisplayWhiteText(text: 'Save'),
                ),
              ),
              const Gap(30),
            ],
          ),
        ),
      ),
    );
  }

  void _createTask() async {
    final title = _titleController.text.trim();
    final note = _noteController.text.trim();
    final category = ref.watch(categoryProvider);
    if (title.isNotEmpty) {
      final task = Task(
        title: title,
        category: category,
        time: Helpers.timeToString(selectedTime),
        date: DateFormat.yMMMd().format(selectedDate),
        note: note,
        isCompleted: false,
      );

      await ref.read(tasksProvider.notifier).createTask(task).then((value) {
        _scheduleDateTime(title, note);
        AppAlerts.displaySnackbar(context, 'Task create successfully');
        context.go(RouteLocation.home);
      });
    } else {
      AppAlerts.displaySnackbar(context, 'Title cannot be empty');
    }
  }
}
