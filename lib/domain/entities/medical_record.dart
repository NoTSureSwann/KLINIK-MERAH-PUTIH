import 'package:equatable/equatable.dart';

class MedicalRecord extends Equatable {
  final String id;
  final String appointmentId;
  final String diagnosis;
  final String prescription;
  final String notes;
  final String? patientName; // Joined
  final String? doctorName; // Joined
  final String? appointmentDate; // Joined

  const MedicalRecord({
    required this.id,
    required this.appointmentId,
    required this.diagnosis,
    required this.prescription,
    required this.notes,
    this.patientName,
    this.doctorName,
    this.appointmentDate,
  });

  @override
  List<Object?> get props => [id, appointmentId, diagnosis, prescription, notes, patientName, doctorName, appointmentDate];
}
