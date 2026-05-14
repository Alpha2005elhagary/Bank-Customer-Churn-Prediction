import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants.dart';
import 'core/theme.dart';
import 'data/datasources/churn_remote_data_source.dart';
import 'data/datasources/python_model_service.dart';
import 'data/datasources/supabase_edge_service.dart';
import 'data/repositories/churn_repository_impl.dart';
import 'data/repositories/history_repository.dart';
import 'domain/usecases/predict_churn_usecase.dart';
import 'data/datasources/market_data_source.dart';
import 'presentation/viewmodels/auth_viewmodel.dart';
import 'presentation/viewmodels/churn_viewmodel.dart';
import 'presentation/viewmodels/market_viewmodel.dart';
import 'presentation/views/splash_view.dart';
import 'presentation/views/home_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  // Initialize Data Sources
  // Initialize Deployed Python Model and Data Sources
  final localModelService = PythonModelDeploymentService();
  final edgeModelService = SupabaseEdgeModelService();
  final remoteDataSource = ChurnRemoteDataSourceImpl(
    localModel: localModelService,
    edgeModel: edgeModelService,
  );

  // Initialize Repositories
  final churnRepository = ChurnRepositoryImpl(remoteDataSource: remoteDataSource);

  // Initialize Use Cases
  final predictChurnUseCase = PredictChurnUseCase(churnRepository);

  // Initialize History Repository
  final historyRepository = PredictionHistoryRepository();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(),
        ),
        ChangeNotifierProvider(
          create: (_) => ChurnViewModel(
            predictChurnUseCase: predictChurnUseCase,
            historyRepository: historyRepository,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => MarketViewModel(dataSource: MockMarketDataSource()),
        ),
      ],
      child: const ChurnInsightApp(),
    ),
  );
}

class ChurnInsightApp extends StatelessWidget {
  const ChurnInsightApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bank Customer Churn Prediction',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashView(),
    );
  }
}
