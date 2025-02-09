import 'job_model.dart';

class Timesheet {
  final String workerName;
  final String date;
  final List<Job> jobs;

  Timesheet({
    required this.workerName,
    required this.date,
    required this.jobs,
  });

  factory Timesheet.empty() {
    return Timesheet(workerName: '', date: '', jobs: []);
  }

  Timesheet copyWith({
    String? workerName,
    String? date,
    List<Job>? jobs,
  }) {
    return Timesheet(
      workerName: workerName ?? this.workerName,
      date: date ?? this.date,
      jobs: jobs ?? this.jobs,
    );
  }
}

