// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'queue_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QueueModel _$QueueModelFromJson(Map<String, dynamic> json) => QueueModel(
      id: json['id'] as String,
      appointmentId: json['appointment_id'] as String,
      queueNumber: (json['queue_number'] as num).toInt(),
      estimatedTime: json['estimated_time'] as String,
      status: json['status'] as String,
      patientName: json['patientName'] as String?,
      doctorName: json['doctorName'] as String?,
    );

Map<String, dynamic> _$QueueModelToJson(QueueModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'patientName': instance.patientName,
      'doctorName': instance.doctorName,
      'appointment_id': instance.appointmentId,
      'queue_number': instance.queueNumber,
      'estimated_time': instance.estimatedTime,
    };
