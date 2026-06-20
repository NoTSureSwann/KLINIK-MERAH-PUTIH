import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/queue.dart';

part 'queue_model.g.dart';

@JsonSerializable()
class QueueModel extends Queue {
  const QueueModel({
    required super.id,
    @JsonKey(name: 'appointment_id') required super.appointmentId,
    @JsonKey(name: 'queue_number') required super.queueNumber,
    @JsonKey(name: 'estimated_time') required super.estimatedTime,
    required super.status,
    super.patientName,
    super.doctorName,
  });

  factory QueueModel.fromJson(Map<String, dynamic> json) => _$QueueModelFromJson(json);
  Map<String, dynamic> toJson() => _$QueueModelToJson(this);

  factory QueueModel.fromEntity(Queue entity) {
    return QueueModel(
      id: entity.id,
      appointmentId: entity.appointmentId,
      queueNumber: entity.queueNumber,
      estimatedTime: entity.estimatedTime,
      status: entity.status,
      patientName: entity.patientName,
      doctorName: entity.doctorName,
    );
  }
}
