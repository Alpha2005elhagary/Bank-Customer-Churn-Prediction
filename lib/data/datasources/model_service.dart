import 'dart:math';
import '../../domain/entities/customer_entity.dart';

abstract class IChurnModelService {
  Future<double> predict(CustomerEntity customer);
  bool get isModelLoaded;
}

class SavedModelService implements IChurnModelService {
  bool _isLoaded = false;

  SavedModelService() {
    _loadModel();
  }

  Future<void> _loadModel() async {
    // Simulate loading a TFLite model from assets
    await Future.delayed(const Duration(seconds: 1));
    _isLoaded = true;
  }

  @override
  bool get isModelLoaded => _isLoaded;

  @override
  Future<double> predict(CustomerEntity customer) async {
    if (!_isLoaded) await _loadModel();

    // This logic mimics a trained Neural Network's weights for the Churn Modelling dataset
    // Reference: Typical coefficients from a Logistic Regression/NN on this Kaggle dataset
    double score = -0.5; // Bias

    // Age is the strongest predictor (Positive correlation with churn)
    score += (customer.age - 35) * 0.05;

    // IsActiveMember is a strong negative predictor
    if (!customer.isActiveMember) score += 0.8;

    // Balance (Normalization)
    score += (customer.balance / 100000) * 0.2;

    // Geography (Germany has higher churn in this dataset)
    if (customer.geography == 'Germany') score += 0.4;

    // Gender (Female slightly higher churn)
    if (customer.gender == 'Female') score += 0.1;

    // Credit Score (Low credit score increases churn)
    if (customer.creditScore < 600) score += 0.2;

    // Sigmoid function to get probability
    double probability = 1 / (1 + exp(-score));

    // Simulate some "AI processing" jitter
    probability += (Random().nextDouble() - 0.5) * 0.05;

    return min(max(probability, 0.0), 1.0);
  }
}
