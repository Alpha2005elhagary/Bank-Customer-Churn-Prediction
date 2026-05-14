import '../../domain/entities/customer_entity.dart';
import '../../domain/repositories/churn_repository.dart';
import '../datasources/churn_remote_data_source.dart';

class ChurnRepositoryImpl implements IChurnRepository {
  final IChurnRemoteDataSource remoteDataSource;

  ChurnRepositoryImpl({required this.remoteDataSource});

  @override
  Future<double> getChurnPrediction(CustomerEntity customer) async {
    return await remoteDataSource.predict(customer);
  }
}
