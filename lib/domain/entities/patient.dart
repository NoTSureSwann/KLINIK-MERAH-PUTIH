import 'package:equatable/equatable.dart';

class Patient extends Equatable {
  final String id;
  final String userId;
  final String nik;
  final String name;
  final String email;
  final String phone;
  final String birthDate;
  final String gender;
  final String address;

  const Patient({
    required this.id,
    required this.userId,
    required this.nik,
    required this.name,
    required this.email,
    required this.phone,
    required this.birthDate,
    required this.gender,
    required this.address,
  });

  @override
  List<Object?> get props => [id, userId, nik, name, email, phone, birthDate, gender, address];
}
