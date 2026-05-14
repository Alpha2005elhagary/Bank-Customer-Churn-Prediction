import '../../domain/entities/customer_entity.dart';
import 'model_service.dart';
import 'python_model_service.dart';
import 'rest_model_service.dart';

class ChurnRemoteDataSourceImpl implements IChurnRemoteDataSource {
  final PythonModelDeploymentService localModel;
  final RestModelService? apiModel;
  bool _useApi = false;

  ChurnRemoteDataSourceImpl({
    required this.localModel,
    this.apiModel,
  });

  void setUseApi(bool value) => _useApi = value;
  void setApiModel(String modelType) => apiModel?.setModel(modelType);

  @override
  Future<double> predict(CustomerEntity customer) async {
    if (_useApi && apiModel != null) {
      try {
        return await apiModel!.predict(customer);
      } catch (e) {
        print('API failed, using local model: $e');
        return await localModel.predict(customer);
      }
    }
    return await localModel.predict(customer);
  }
}
