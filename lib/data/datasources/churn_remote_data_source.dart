import '../../domain/entities/customer_entity.dart';
import 'model_service.dart';
import 'python_model_service.dart';
import 'supabase_edge_service.dart';

abstract class IChurnRemoteDataSource {
  Future<double> predict(CustomerEntity customer);
}

class ChurnRemoteDataSourceImpl implements IChurnRemoteDataSource {
  final PythonModelDeploymentService localModel;
  final SupabaseEdgeModelService edgeModel;
  bool _useCloud = true;

  ChurnRemoteDataSourceImpl({
    required this.localModel,
    required this.edgeModel,
  });

  void setUseCloud(bool value) => _useCloud = value;

  @override
  Future<double> predict(CustomerEntity customer) async {
    if (_useCloud) {
      try {
        return await edgeModel.predict(customer);
      } catch (e) {
        print('Cloud prediction failed, using local fallback: $e');
        return await localModel.predict(customer);
      }
    }
    return await localModel.predict(customer);
  }
}
