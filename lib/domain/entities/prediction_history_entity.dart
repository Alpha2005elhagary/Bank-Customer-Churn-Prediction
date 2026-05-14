import '../../domain/entities/customer_entity.dart';

class PredictionHistoryEntity {
  final String id;
  final CustomerEntity customer;
  final double probability;
  final DateTime timestamp;

  PredictionHistoryEntity({
    required this.id,
    required this.customer,
    required this.probability,
    required this.timestamp,
  });

  bool get isHighRisk => probability > 0.5;
}
