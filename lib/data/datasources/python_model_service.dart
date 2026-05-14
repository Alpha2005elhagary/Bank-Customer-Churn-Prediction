import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import '../../domain/entities/customer_entity.dart';
import 'model_service.dart';

class PythonModelDeploymentService implements IChurnModelService {
  Map<String, dynamic>? _params;
  bool _isLoaded = false;

  PythonModelDeploymentService() {
    _loadModelParams();
  }

  Future<void> _loadModelParams() async {
    try {
      final String response = await rootBundle.loadString('assets/models/churn_model_params.json');
      _params = json.decode(response);
      _isLoaded = true;
    } catch (e) {
      print('Error loading Python model params: $e');
      _isLoaded = false;
    }
  }

  @override
  bool get isModelLoaded => _isLoaded;

  @override
  Future<double> predict(CustomerEntity customer) async {
    if (!_isLoaded || _params == null) {
      await _loadModelParams();
      if (!_isLoaded) return 0.5; // Default fallback
    }

    // 1. Prepare Features (Matching the Python script columns)
    // ['CreditScore', 'Age', 'Tenure', 'Balance', 'NumOfProducts', 'HasCrCard', 'IsActiveMember', 'EstimatedSalary', 'Geography_Germany', 'Geography_Spain', 'Gender_Male']
    List<double> features = [
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
    ];

    // 2. Scale Features (Using mean and scale from Python StandardScaler)
    List<double> means = List<double>.from(_params!['mean']);
    List<double> scales = List<double>.from(_params!['scale']);
    List<double> scaledFeatures = [];

    for (int i = 0; i < features.length; i++) {
      scaledFeatures.add((features[i] - means[i]) / scales[i]);
    }

    // 3. Calculate Logistic Regression (coefficients * features + intercept)
    List<double> coeffs = List<double>.from(_params!['coefficients']);
    double intercept = _params!['intercept'];
    
    double z = intercept;
    for (int i = 0; i < scaledFeatures.length; i++) {
      z += scaledFeatures[i] * coeffs[i];
    }

    // 4. Sigmoid Function
    double probability = 1 / (1 + exp(-z));

    return probability;
  }
}
