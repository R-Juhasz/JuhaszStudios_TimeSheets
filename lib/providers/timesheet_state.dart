import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/timesheet_model.dart';
import '../models/job_model.dart';

class TimesheetNotifier extends StateNotifier<Timesheet> {
  TimesheetNotifier() : super(Timesheet.empty());

  void updateWorkerName(String name) {
    state = state.copyWith(workerName: name);
  }

  void updateDate(String date) {
    state = state.copyWith(date: date);
  }

  void addJob(Job job) {
    final updatedJobs = List<Job>.from(state.jobs)..add(job);
    state = state.copyWith(jobs: updatedJobs);
  }

  void resetJobs() {
    state = state.copyWith(jobs: []);
  }
}

final timesheetProvider =
StateNotifierProvider<TimesheetNotifier, Timesheet>((ref) {
  return TimesheetNotifier();
});
