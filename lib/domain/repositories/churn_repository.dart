import '../entities/customer_entity.dart';

abstract class IChurnRepository {
  Future<double> getChurnPrediction(CustomerEntity customer);
}
