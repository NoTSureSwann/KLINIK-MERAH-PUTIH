import 'package:equatable/equatable.dart';

class Queue extends Equatable {
  final String id;
  final String appointmentId;
  final int queueNumber;
  final String estimatedTime;
  final String status;
  final String? patientName; // Joined
  final String? doctorName; // Joined

  const Queue({
    required this.id,
    required this.appointmentId,
    required this.queueNumber,
    required this.estimatedTime,
    required this.status,
    this.patientName,
    this.doctorName,
  });

  @override
  List<Object?> get props => [id, appointmentId, queueNumber, estimatedTime, status, patientName, doctorName];
}
