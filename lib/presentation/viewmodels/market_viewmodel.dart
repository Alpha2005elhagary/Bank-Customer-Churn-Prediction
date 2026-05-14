import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/entities/market_entity.dart';
import '../../data/datasources/market_data_source.dart';

class MarketViewModel with ChangeNotifier {
  final IMarketDataSource dataSource;
  List<MarketEntity> _stocks = [];
  bool _isLoading = false;
  Timer? _timer;

  MarketViewModel({required this.dataSource}) {
    startUpdates();
  }

  List<MarketEntity> get stocks => _stocks;
  bool get isLoading => _isLoading;

  void startUpdates() {
    fetchData();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      fetchData();
    });
  }

  Future<void> fetchData() async {
    try {
      _stocks = await dataSource.getMarketData();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching market data: $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
