import 'package:flutter_email_sender/flutter_email_sender.dart';

class EmailService {
  Future<void> sendEmail({required String recipient, required String attachmentPath}) async {
    final Email email = Email(
      body: "Please find the attached timesheet PDF.",
      subject: "Timesheet PDF",
      recipients: [recipient],
      attachmentPaths: [attachmentPath],
      isHTML: false,
    );
    await FlutterEmailSender.send(email);
  }
}
