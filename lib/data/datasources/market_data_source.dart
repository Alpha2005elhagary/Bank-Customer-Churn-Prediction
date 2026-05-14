import 'dart:async';
import 'dart:math';
import '../../domain/entities/market_entity.dart';

abstract class IMarketDataSource {
  Future<List<MarketEntity>> getMarketData();
}

class MockMarketDataSource implements IMarketDataSource {
  final List<MarketEntity> _initialData = [
    MarketEntity(symbol: 'AAPL', name: 'Apple Inc.', price: 189.43, changePercentage: 1.2, isUp: true),
    MarketEntity(symbol: 'JPM', name: 'JP Morgan', price: 195.12, changePercentage: -0.4, isUp: false),
    MarketEntity(symbol: 'GS', name: 'Goldman Sachs', price: 412.55, changePercentage: 2.1, isUp: true),
    MarketEntity(symbol: 'EUR/USD', name: 'Euro / Dollar', price: 1.08, changePercentage: 0.15, isUp: true),
    MarketEntity(symbol: 'GBP/USD', name: 'Pound / Dollar', price: 1.26, changePercentage: -0.2, isUp: false),
  ];

  @override
  Future<List<MarketEntity>> getMarketData() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Simulate slight price fluctuations
    return _initialData.map((e) {
      final variation = (Random().nextDouble() - 0.5) * 0.1;
      final newPrice = e.price * (1 + variation / 100);
      return MarketEntity(
        symbol: e.symbol,
        name: e.name,
        price: newPrice,
        changePercentage: e.changePercentage + variation,
        isUp: variation >= 0,
      );
    }).toList();
  }
}
