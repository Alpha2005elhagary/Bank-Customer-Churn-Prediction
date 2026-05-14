import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/customer_entity.dart';
import 'model_service.dart';

class SupabaseEdgeModelService implements IChurnModelService {
  final _client = Supabase.instance.client;

  @override
  bool get isModelLoaded => true;

  @override
  Future<double> predict(CustomerEntity customer) async {
    try {
      final response = await _client.functions.invoke(
        'predict-churn',
        body: {
          'credit_score': customer.creditScore,
          'age': customer.age,
          'tenure': customer.tenure,
          'balance': customer.balance,
          'num_products': customer.numOfProducts,
          'has_card': customer.hasCrCard,
          'is_active': customer.isActiveMember,
          'salary': customer.estimatedSalary,
          'geography': customer.geography,
          'gender': customer.gender,
        },
      );

      if (response.status == 200) {
        return response.data['probability'];
      } else {
        throw Exception('Edge Function Error: ${response.status}');
      }
    } catch (e) {
      print('Supabase Edge Function Error: $e');
      rethrow;
    }
  }
}
