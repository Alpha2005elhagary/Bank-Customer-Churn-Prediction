import '../entities/customer_entity.dart';
import '../repositories/churn_repository.dart';

class PredictChurnUseCase {
  final IChurnRepository repository;

  PredictChurnUseCase(this.repository);

  Future<double> execute(CustomerEntity customer) async {
    return await repository.getChurnPrediction(customer);
  }
}
