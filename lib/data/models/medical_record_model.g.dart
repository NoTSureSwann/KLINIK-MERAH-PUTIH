// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medical_record_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MedicalRecordModel _$MedicalRecordModelFromJson(Map<String, dynamic> json) =>
    MedicalRecordModel(
      id: json['id'] as String,
      appointmentId: json['appointment_id'] as String,
      diagnosis: json['diagnosis'] as String,
      prescription: json['prescription'] as String,
      notes: json['notes'] as String,
      patientName: json['patientName'] as String?,
      doctorName: json['doctorName'] as String?,
      appointmentDate: json['appointmentDate'] as String?,
    );

Map<String, dynamic> _$MedicalRecordModelToJson(MedicalRecordModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'diagnosis': instance.diagnosis,
      'prescription': instance.prescription,
      'notes': instance.notes,
      'patientName': instance.patientName,
      'doctorName': instance.doctorName,
      'appointmentDate': instance.appointmentDate,
      'appointment_id': instance.appointmentId,
    };
