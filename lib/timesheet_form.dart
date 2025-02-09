import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'models/job_model.dart';
import 'providers/timesheet_state.dart';
import 'services/pdf_service.dart';
import 'services/email_service.dart';

class TimesheetForm extends ConsumerStatefulWidget {
  const TimesheetForm({super.key});
  @override
  _TimesheetFormState createState() => _TimesheetFormState();
}

class _TimesheetFormState extends ConsumerState<TimesheetForm> {
  final _formKey = GlobalKey<FormState>();
  File? _pdfFile;
  final PdfService _pdfService = PdfService();
  final EmailService _emailService = EmailService();
  final TextEditingController _workerNameController = TextEditingController();
  final TextEditingController _recipientEmailController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  // A list of GlobalKeys to access each JobEntryWidget's state.
  final List<GlobalKey<_JobEntryWidgetState>> _jobEntryKeys = [];

  @override
  void initState() {
    super.initState();
    _addJobEntry(); // Start with one job entry.
  }

  Future<File> _savePdfFile(Uint8List pdfData) async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final timesheetsDir = Directory('${appDocDir.path}/timesheets');
    if (!await timesheetsDir.exists()) {
      await timesheetsDir.create(recursive: true);
    }
    final fileName = 'timesheet_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File('${timesheetsDir.path}/$fileName');
    await file.writeAsBytes(pdfData);
    return file;
  }

  Future<void> _generateAndSavePdf() async {
    // Reset any previously added jobs.
    ref.read(timesheetProvider.notifier).resetJobs();
    // Validate and add each job entry.
    for (var key in _jobEntryKeys) {
      if (!(key.currentState?.validate() ?? false)) return;
      ref.read(timesheetProvider.notifier).addJob(key.currentState!.getJob());
    }
    // Update the worker's name and date.
    ref.read(timesheetProvider.notifier).updateWorkerName(_workerNameController.text);
    ref.read(timesheetProvider.notifier).updateDate(_dateController.text);

    final timesheet = ref.read(timesheetProvider);
    final pdfData = await _pdfService.generatePdf(timesheet);
    final file = await _savePdfFile(pdfData);
    setState(() {
      _pdfFile = file;
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("PDF generated successfully!")));
  }

  Future<void> _sendEmail() async {
    if (_pdfFile == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Please generate the PDF first.")));
      return;
    }
    final recipientEmail = _recipientEmailController.text;
    if (recipientEmail.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Enter recipient email address.")));
      return;
    }
    try {
      await _emailService.sendEmail(
          recipient: recipientEmail, attachmentPath: _pdfFile!.path);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Email sent successfully!")));
    } catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Failed to send email: $error")));
    }
  }

  Future<void> _previewPdf() async {
    if (_pdfFile == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Please generate the PDF first.")));
      return;
    }
    await Printing.layoutPdf(onLayout: (format) async => _pdfFile!.readAsBytes());
  }

  void _addJobEntry() {
    if (_jobEntryKeys.length < 20) {
      setState(() {
        _jobEntryKeys.add(GlobalKey<_JobEntryWidgetState>());
      });
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Maximum 20 jobs allowed.")));
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = "${picked.month}/${picked.day}/${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Worker name field.
            TextFormField(
              controller: _workerNameController,
              decoration: const InputDecoration(labelText: "Worker Name"),
              validator: (value) =>
              value == null || value.isEmpty ? "Enter worker name" : null,
            ),
            // Recipient email field.
            TextFormField(
              controller: _recipientEmailController,
              decoration: const InputDecoration(labelText: "Recipient Email"),
              validator: (value) =>
              value == null || value.isEmpty ? "Enter recipient email" : null,
            ),
            // Date field with a date picker.
            TextFormField(
              controller: _dateController,
              decoration: const InputDecoration(
                labelText: "Date",
                suffixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: _selectDate,
              validator: (value) =>
              value == null || value.isEmpty ? "Select a date" : null,
            ),
            const SizedBox(height: 20),
            const Text("Jobs", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            // List of job entries with a remove button.
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _jobEntryKeys.length,
              itemBuilder: (context, index) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // The job entry form.
                    Expanded(child: JobEntryWidget(key: _jobEntryKeys[index])),
                    // Remove button (only enable if more than one job entry exists).
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        if (_jobEntryKeys.length > 1) {
                          setState(() {
                            _jobEntryKeys.removeAt(index);
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("At least one job entry is required.")));
                        }
                      },
                    ),
                  ],
                );
              },
            ),
            ElevatedButton(onPressed: _addJobEntry, child: const Text("Add Job")),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _generateAndSavePdf();
                }
              },
              child: const Text("Generate PDF"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: _previewPdf, child: const Text("Preview PDF")),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _sendEmail();
                }
              },
              child: const Text("Send Email"),
            ),
          ],
        ),
      ),
    );
  }
}

class JobEntryWidget extends StatefulWidget {
  const JobEntryWidget({super.key});
  @override
  _JobEntryWidgetState createState() => _JobEntryWidgetState();
}

class _JobEntryWidgetState extends State<JobEntryWidget> {
  final _jobFormKey = GlobalKey<FormState>();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  final TextEditingController _jobNumberController = TextEditingController();
  final TextEditingController _jobDescriptionController = TextEditingController();

  bool validate() {
    return _jobFormKey.currentState?.validate() ?? false;
  }

  Job getJob() {
    return Job(
      address: _addressController.text,
      startTime: _startTimeController.text,
      endTime: _endTimeController.text,
      jobNumber: _jobNumberController.text,
      jobDescription: _jobDescriptionController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _jobFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _addressController,
            decoration: const InputDecoration(labelText: "Job Address"),
            validator: (value) => value == null || value.isEmpty ? "Enter job address" : null,
          ),
          TextFormField(
            controller: _startTimeController,
            decoration: const InputDecoration(labelText: "Start Time"),
            validator: (value) => value == null || value.isEmpty ? "Enter start time" : null,
          ),
          TextFormField(
            controller: _endTimeController,
            decoration: const InputDecoration(labelText: "End Time"),
            validator: (value) => value == null || value.isEmpty ? "Enter end time" : null,
          ),
          TextFormField(
            controller: _jobNumberController,
            decoration: const InputDecoration(labelText: "Job Number"),
            validator: (value) => value == null || value.isEmpty ? "Enter job number" : null,
          ),
          TextFormField(
            controller: _jobDescriptionController,
            decoration: const InputDecoration(labelText: "Job Description"),
            validator: (value) => value == null || value.isEmpty ? "Enter job description" : null,
          ),
          const Divider(thickness: 2),
        ],
      ),
    );
  }
}



