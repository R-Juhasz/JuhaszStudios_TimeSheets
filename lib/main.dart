import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:juhaszstdios_timesheets/saved_timesheets_screen.dart';
import 'timesheet_form.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      title: 'JuhaszStudios Timesheets',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const TimesheetFormWithAppBar(),
    );
  }
}

class TimesheetFormWithAppBar extends StatelessWidget {
  const TimesheetFormWithAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("JuhaszStudios Timesheets"),
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_open),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SavedTimesheetsScreen()),
              );
            },
          ),
        ],
      ),
      body: TimesheetForm(),
    );
  }
}
