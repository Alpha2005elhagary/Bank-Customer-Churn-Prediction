import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';
import '../../domain/entities/customer_entity.dart';
import 'model_service.dart';

class TfliteModelService implements IChurnModelService {
  Interpreter? _interpreter;
  bool _isLoaded = false;

  TfliteModelService() {
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      // The model file should be placed in assets/models/churn_model.tflite
      _interpreter = await Interpreter.fromAsset('assets/models/churn_model.tflite');
      _isLoaded = true;
    } catch (e) {
      print('Error loading TFLite model: $e');
      _isLoaded = false;
    }
  }

  @override
  bool get isModelLoaded => _isLoaded;

  @override
  Future<double> predict(CustomerEntity customer) async {
    if (!_isLoaded || _interpreter == null) {
      // Fallback to the intelligent mock logic if model file is missing
      return _fallbackPrediction(customer);
    }

    // Prepare input tensor (Example for Churn Modelling dataset)
    // The order should match your model's training features:
    // [CreditScore, Age, Tenure, Balance, NumOfProducts, HasCrCard, IsActiveMember, EstimatedSalary, Geography_Germany, Geography_Spain, Gender_Male]
    var input = [
      [
        customer.creditScore.toDouble(),
        customer.age.toDouble(),
        customer.tenure.toDouble(),
        customer.balance,
        customer.numOfProducts.toDouble(),
        customer.hasCrCard ? 1.0 : 0.0,
        customer.isActiveMember ? 1.0 : 0.0,
        customer.estimatedSalary,
        customer.geography == 'Germany' ? 1.0 : 0.0,
        customer.geography == 'Spain' ? 1.0 : 0.0,
        customer.gender == 'Male' ? 1.0 : 0.0,
      ]
    ];

    // Prepare output tensor
    var output = List<double>.filled(1, 0).reshape([1, 1]);

    // Run inference
    _interpreter!.run(input, output);

    return output[0][0];
  }

  Future<double> _fallbackPrediction(CustomerEntity customer) async {
    // Intelligent fallback logic as a backup
    double score = (customer.age / 100) + (customer.balance / 200000) - (customer.isActiveMember ? 0.5 : 0);
    return score.clamp(0.0, 1.0);
  }
}
