import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';

class SavedTimesheetsScreen extends StatefulWidget {
  @override
  _SavedTimesheetsScreenState createState() => _SavedTimesheetsScreenState();
}

class _SavedTimesheetsScreenState extends State<SavedTimesheetsScreen> {
  late Future<List<FileSystemEntity>> _filesFuture;

  @override
  void initState() {
    super.initState();
    _filesFuture = _loadFiles();
  }

  Future<List<FileSystemEntity>> _loadFiles() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final timesheetsDir = Directory('${appDocDir.path}/timesheets');
    if (!(await timesheetsDir.exists())) {
      await timesheetsDir.create(recursive: true);
    }
    // List all files in the timesheets directory.
    return timesheetsDir.list().toList();
  }

  Future<void> _refreshFiles() async {
    setState(() {
      _filesFuture = _loadFiles();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Saved Timesheets"),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshFiles,
          )
        ],
      ),
      body: FutureBuilder<List<FileSystemEntity>>(
        future: _filesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          final files = snapshot.data!;
          if (files.isEmpty) {
            return Center(child: Text("No saved timesheets."));
          }
          return ListView.builder(
            itemCount: files.length,
            itemBuilder: (context, index) {
              final file = files[index];
              final fileName = file.path.split(Platform.pathSeparator).last;
              return ListTile(
                title: Text(fileName),
                subtitle: Text(file.path),
                onTap: () async {
                  // Preview the PDF using the Printing package.
                  await Printing.layoutPdf(
                    onLayout: (format) async => File(file.path).readAsBytes(),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
