import 'package:equatable/equatable.dart';

class Doctor extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String email;
  final String phone;
  final String specialization;
  final double consultationFee;
  final String schedule;

  const Doctor({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.specialization,
    required this.consultationFee,
    required this.schedule,
  });

  @override
  List<Object?> get props => [id, userId, name, email, phone, specialization, consultationFee, schedule];
}
