import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/prediction_history_entity.dart';
import '../../domain/entities/customer_entity.dart';

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

    try {
      final response = await _client
          .from('predictions')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      final List data = response as List;
      return data.map((json) {
        return PredictionHistoryEntity(
          id: json['id'].toString(),
          customer: CustomerEntity(
            surname: json['customer_surname'] ?? '',
            creditScore: json['credit_score'] ?? 0,
            geography: json['geography'] ?? '',
            gender: json['gender'] ?? '',
            age: json['age'] ?? 0,
            tenure: json['tenure'] ?? 0,
            balance: (json['balance'] as num).toDouble(),
            numOfProducts: json['num_products'] ?? 0,
            hasCrCard: json['has_card'] ?? false,
            isActiveMember: json['is_active'] ?? false,
            estimatedSalary: (json['salary'] as num).toDouble(),
          ),
          probability: (json['probability'] as num).toDouble(),
          timestamp: DateTime.parse(json['created_at']),
        );
      }).toList();
    } catch (e) {
      // If table doesn't exist yet or other error, return empty
      return [];
    }
  }
}
