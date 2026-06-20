import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/patient.dart';

part 'patient_model.g.dart';

@JsonSerializable()
class PatientModel extends Patient {
  const PatientModel({
    required super.id,
    required super.userId,
    required super.nik,
    required super.name,
    required super.email,
    required super.phone,
    required super.birthDate,
    required super.gender,
    required super.address,
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) => _$PatientModelFromJson(json);
  Map<String, dynamic> toJson() => _$PatientModelToJson(this);

  factory PatientModel.fromEntity(Patient entity) {
    return PatientModel(
      id: entity.id,
      userId: entity.userId,
      nik: entity.nik,
      name: entity.name,
      email: entity.email,
      phone: entity.phone,
      birthDate: entity.birthDate,
      gender: entity.gender,
      address: entity.address,
    );
  }
}
