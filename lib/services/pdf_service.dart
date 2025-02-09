import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;
import '../models/timesheet_model.dart';

class PdfService {
  Future<Uint8List> generatePdf(Timesheet timesheet) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("Timesheet", style: pw.TextStyle(fontSize: 24)),
              pw.SizedBox(height: 20),
              pw.Row(
                children: [
                  pw.Text("Worker Name: ", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text(timesheet.workerName),
                ],
              ),
              pw.Row(
                children: [
                  pw.Text("Date: ", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text(timesheet.date),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Text("Jobs", style: pw.TextStyle(fontSize: 20)),
              pw.SizedBox(height: 10),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Padding(padding: pw.EdgeInsets.all(4), child: pw.Text("Address", style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: pw.EdgeInsets.all(4), child: pw.Text("Start Time", style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: pw.EdgeInsets.all(4), child: pw.Text("End Time", style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: pw.EdgeInsets.all(4), child: pw.Text("Job Number", style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: pw.EdgeInsets.all(4), child: pw.Text("Job Description", style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    ],
                  ),
                  ...timesheet.jobs.map((job) => pw.TableRow(
                    children: [
                      pw.Padding(padding: pw.EdgeInsets.all(4), child: pw.Text(job.address)),
                      pw.Padding(padding: pw.EdgeInsets.all(4), child: pw.Text(job.startTime)),
                      pw.Padding(padding: pw.EdgeInsets.all(4), child: pw.Text(job.endTime)),
                      pw.Padding(padding: pw.EdgeInsets.all(4), child: pw.Text(job.jobNumber)),
                      pw.Padding(padding: pw.EdgeInsets.all(4), child: pw.Text(job.jobDescription)),
                    ],
                  )),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}

