// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appointment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppointmentModel _$AppointmentModelFromJson(Map<String, dynamic> json) =>
    AppointmentModel(
      id: json['id'] as String,
      patientId: json['patient_id'] as String,
      doctorId: json['doctor_id'] as String,
      appointmentDate: json['appointment_date'] as String,
      status: json['status'] as String,
      patientName: json['patientName'] as String?,
      doctorName: json['doctorName'] as String?,
    );

Map<String, dynamic> _$AppointmentModelToJson(AppointmentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patient_id': instance.patientId,
      'doctor_id': instance.doctorId,
      'appointment_date': instance.appointmentDate,
      'status': instance.status,
      'patientName': instance.patientName,
      'doctorName': instance.doctorName,
    };
