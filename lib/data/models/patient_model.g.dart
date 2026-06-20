// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patient_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PatientModel _$PatientModelFromJson(Map<String, dynamic> json) => PatientModel(
  id: json['id'] as String,
  userId: json['userId'] as String,
  nik: json['nik'] as String,
  name: json['name'] as String,
  email: json['email'] as String,
  phone: json['phone'] as String,
  birthDate: json['birthDate'] as String,
  gender: json['gender'] as String,
  address: json['address'] as String,
);

Map<String, dynamic> _$PatientModelToJson(PatientModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'nik': instance.nik,
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phone,
      'birthDate': instance.birthDate,
      'gender': instance.gender,
      'address': instance.address,
    };
