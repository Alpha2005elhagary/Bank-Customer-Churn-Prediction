import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/customer_entity.dart';
import 'model_service.dart';

class RestModelService implements IChurnModelService {
  final String baseUrl;
  String _selectedModel = 'rf';

  RestModelService({this.baseUrl = 'http://10.0.2.2:8000'}); // 10.0.2.2 is localhost for Android Emulator

  void setModel(String modelType) {
    _selectedModel = modelType;
  }

  @override
  bool get isModelLoaded => true;

  @override
  Future<double> predict(CustomerEntity customer) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/predict'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
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
          'model_type': _selectedModel,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['probability'];
      } else {
        throw Exception('Failed to get prediction from API');
      }
    } catch (e) {
      print('API Error: $e. Falling back to local model.');
      rethrow; // Let the data source handle fallback
    }
  }
}
