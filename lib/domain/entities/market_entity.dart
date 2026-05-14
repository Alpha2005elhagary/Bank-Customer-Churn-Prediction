class MarketEntity {
  final String symbol;
  final String name;
  final double price;
  final double changePercentage;
  final bool isUp;

  MarketEntity({
    required this.symbol,
    required this.name,
    required this.price,
    required this.changePercentage,
    required this.isUp,
  });
}
