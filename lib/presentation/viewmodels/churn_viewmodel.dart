import 'package:flutter/material.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/entities/prediction_history_entity.dart';
import '../../domain/usecases/predict_churn_usecase.dart';
import '../../data/repositories/history_repository.dart';

class ChurnViewModel with ChangeNotifier {
  final PredictChurnUseCase predictChurnUseCase;
  final PredictionHistoryRepository historyRepository;

  ChurnViewModel({
    required this.predictChurnUseCase,
    required this.historyRepository,
  });

  CustomerEntity _currentCustomer = CustomerEntity.empty();
  bool _isPredicting = false;
  double? _lastPrediction;
  String? _errorMessage;
  final List<PredictionHistoryEntity> _history = [];

  CustomerEntity get currentCustomer => _currentCustomer;
  bool get isPredicting => _isPredicting;
  double? get lastPrediction => _lastPrediction;
  String? get errorMessage => _errorMessage;
  List<PredictionHistoryEntity> get history => List.unmodifiable(_history);

  void updateCustomer(CustomerEntity customer) {
    _currentCustomer = customer;
    notifyListeners();
  }

  Future<void> predictChurn() async {
    _isPredicting = true;
    _lastPrediction = null;
    _errorMessage = null;
    notifyListeners();

    try {
      _lastPrediction = await predictChurnUseCase.execute(_currentCustomer);
      _currentCustomer = _currentCustomer.copyWith(churnProbability: _lastPrediction);
      
      final historyItem = PredictionHistoryEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        customer: _currentCustomer,
        probability: _lastPrediction!,
        timestamp: DateTime.now(),
      );

      _history.insert(0, historyItem);
      
      // Persist to Supabase
      await historyRepository.savePrediction(historyItem);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isPredicting = false;
      notifyListeners();
    }
  }

  void reset() {
    _currentCustomer = CustomerEntity.empty();
    _lastPrediction = null;
    _isPredicting = false;
    _errorMessage = null;
    notifyListeners();
  }
}
