import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/medical_record.dart';

part 'medical_record_model.g.dart';

@JsonSerializable()
class MedicalRecordModel extends MedicalRecord {
  const MedicalRecordModel({
    required super.id,
    @JsonKey(name: 'appointment_id') required super.appointmentId,
    required super.diagnosis,
    required super.prescription,
    required super.notes,
    super.patientName,
    super.doctorName,
    super.appointmentDate,
  });

  factory MedicalRecordModel.fromJson(Map<String, dynamic> json) => _$MedicalRecordModelFromJson(json);
  Map<String, dynamic> toJson() => _$MedicalRecordModelToJson(this);

  factory MedicalRecordModel.fromEntity(MedicalRecord entity) {
    return MedicalRecordModel(
      id: entity.id,
      appointmentId: entity.appointmentId,
      diagnosis: entity.diagnosis,
      prescription: entity.prescription,
      notes: entity.notes,
      patientName: entity.patientName,
      doctorName: entity.doctorName,
      appointmentDate: entity.appointmentDate,
    );
  }
}
