import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/payment.dart';

part 'payment_model.g.dart';

@JsonSerializable()
class PaymentModel extends Payment {
  const PaymentModel({
    required super.id,
    @JsonKey(name: 'patient_id') required super.patientId,
    @JsonKey(name: 'doctor_id') required super.doctorId,
    required super.amount,
    @JsonKey(name: 'payment_method') required super.paymentMethod,
    @JsonKey(name: 'invoice_number') required super.invoiceNumber,
    required super.status,
    super.patientName,
    super.doctorName,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) => _$PaymentModelFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentModelToJson(this);

  factory PaymentModel.fromEntity(Payment entity) {
    return PaymentModel(
      id: entity.id,
      patientId: entity.patientId,
      doctorId: entity.doctorId,
      amount: entity.amount,
      paymentMethod: entity.paymentMethod,
      invoiceNumber: entity.invoiceNumber,
      status: entity.status,
      patientName: entity.patientName,
      doctorName: entity.doctorName,
    );
  }
}
