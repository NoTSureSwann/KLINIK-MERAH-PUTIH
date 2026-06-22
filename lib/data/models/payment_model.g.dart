// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentModel _$PaymentModelFromJson(Map<String, dynamic> json) => PaymentModel(
  id: json['id'] as String,
  patientId: json['patient_id'] as String,
  doctorId: json['doctor_id'] as String,
  amount: (json['amount'] as num).toDouble(),
  paymentMethod: json['payment_method'] as String,
  invoiceNumber: json['invoice_number'] as String,
  status: json['status'] as String,
  patientName: json['patientName'] as String?,
  doctorName: json['doctorName'] as String?,
);

Map<String, dynamic> _$PaymentModelToJson(PaymentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patient_id': instance.patientId,
      'doctor_id': instance.doctorId,
      'amount': instance.amount,
      'payment_method': instance.paymentMethod,
      'invoice_number': instance.invoiceNumber,
      'status': instance.status,
      'patientName': instance.patientName,
      'doctorName': instance.doctorName,
    };
