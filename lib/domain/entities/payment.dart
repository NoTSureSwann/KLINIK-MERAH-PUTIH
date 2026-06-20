import 'package:equatable/equatable.dart';

class Payment extends Equatable {
  final String id;
  final String patientId;
  final String doctorId;
  final double amount;
  final String paymentMethod;
  final String invoiceNumber;
  final String status;
  final String? patientName; // Joined
  final String? doctorName; // Joined

  const Payment({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.amount,
    required this.paymentMethod,
    required this.invoiceNumber,
    required this.status,
    this.patientName,
    this.doctorName,
  });

  @override
  List<Object?> get props => [
        id,
        patientId,
        doctorId,
        amount,
        paymentMethod,
        invoiceNumber,
        status,
        patientName,
        doctorName,
      ];
}
