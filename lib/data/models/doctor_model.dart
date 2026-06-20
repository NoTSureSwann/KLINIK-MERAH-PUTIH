import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/doctor.dart';

part 'doctor_model.g.dart';

@JsonSerializable()
class DoctorModel extends Doctor {
  const DoctorModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.email,
    required super.phone,
    required super.specialization,
    required super.consultationFee,
    required super.schedule,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) => _$DoctorModelFromJson(json);
  Map<String, dynamic> toJson() => _$DoctorModelToJson(this);

  factory DoctorModel.fromEntity(Doctor entity) {
    return DoctorModel(
      id: entity.id,
      userId: entity.userId,
      name: entity.name,
      email: entity.email,
      phone: entity.phone,
      specialization: entity.specialization,
      consultationFee: entity.consultationFee,
      schedule: entity.schedule,
    );
  }
}
