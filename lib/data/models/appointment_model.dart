import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/appointment.dart';

part 'appointment_model.g.dart';

@JsonSerializable()
class AppointmentModel extends Appointment {
  const AppointmentModel({
    required super.id,
    @JsonKey(name: 'patient_id') required super.patientId,
    @JsonKey(name: 'doctor_id') required super.doctorId,
    @JsonKey(name: 'appointment_date') required super.appointmentDate,
    required super.status,
    super.patientName,
    super.doctorName,
    super.symptoms,
    super.complaints,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) => _$AppointmentModelFromJson(json);
  Map<String, dynamic> toJson() => _$AppointmentModelToJson(this);

  factory AppointmentModel.fromEntity(Appointment entity) {
    return AppointmentModel(
      id: entity.id,
      patientId: entity.patientId,
      doctorId: entity.doctorId,
      appointmentDate: entity.appointmentDate,
      status: entity.status,
      patientName: entity.patientName,
      doctorName: entity.doctorName,
      symptoms: entity.symptoms,
      complaints: entity.complaints,
    );
  }
}
