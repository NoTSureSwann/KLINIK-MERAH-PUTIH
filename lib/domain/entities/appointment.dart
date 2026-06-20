import 'package:equatable/equatable.dart';

class Appointment extends Equatable {
  final String id;
  final String patientId;
  final String doctorId;
  final String appointmentDate;
  final String status;
  final String? patientName; // joined from patient
  final String? doctorName; // joined from doctor

  const Appointment({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.appointmentDate,
    required this.status,
    this.patientName,
    this.doctorName,
  });

  @override
  List<Object?> get props => [id, patientId, doctorId, appointmentDate, status, patientName, doctorName];
}
