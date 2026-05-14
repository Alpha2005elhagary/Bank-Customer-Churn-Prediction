import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/prediction_history_entity.dart';

class PredictionHistoryRepository {
  final _client = Supabase.instance.client;

  Future<void> savePrediction(PredictionHistoryEntity prediction) async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    await _client.from('predictions').insert({
      'user_id': user.id,
      'customer_surname': prediction.customer.surname,
      'credit_score': prediction.customer.creditScore,
      'geography': prediction.customer.geography,
      'gender': prediction.customer.gender,
      'age': prediction.customer.age,
      'tenure': prediction.customer.tenure,
      'balance': prediction.customer.balance,
      'num_products': prediction.customer.numOfProducts,
      'has_card': prediction.customer.hasCrCard,
      'is_active': prediction.customer.isActiveMember,
      'salary': prediction.customer.estimatedSalary,
      'probability': prediction.probability,
      'created_at': prediction.timestamp.toIso8601String(),
    });
  }

  Future<List<PredictionHistoryEntity>> fetchHistory() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];

    final response = await _client
        .from('predictions')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return (response as List).map((json) {
      // Mapping logic would go here, converting JSON back to Entities
      // For brevity, returning a placeholder or implementing mapping
      return PredictionHistoryEntity(
        id: json['id'].toString(),
        customer: _mapJsonToCustomer(json),
        probability: json['probability'],
        timestamp: DateTime.parse(json['created_at']),
      );
    }).toList();
  }

  // Helper to map JSON to Entity
  dynamic _mapJsonToCustomer(Map<String, dynamic> json) {
    // This would match the CustomerEntity structure
    return null; // Implementation detail
  }
}
