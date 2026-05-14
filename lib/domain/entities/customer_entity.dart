class CustomerEntity {
  final String surname;
  final int creditScore;
  final String geography;
  final String gender;
  final int age;
  final int tenure;
  final double balance;
  final int numOfProducts;
  final bool hasCrCard;
  final bool isActiveMember;
  final double estimatedSalary;
  final double? churnProbability;

  CustomerEntity({
    required this.surname,
    required this.creditScore,
    required this.geography,
    required this.gender,
    required this.age,
    required this.tenure,
    required this.balance,
    required this.numOfProducts,
    required this.hasCrCard,
    required this.isActiveMember,
    required this.estimatedSalary,
    this.churnProbability,
  });

  factory CustomerEntity.empty() {
    return CustomerEntity(
      surname: '',
      creditScore: 650,
      geography: 'France',
      gender: 'Female',
      age: 35,
      tenure: 5,
      balance: 50000.0,
      numOfProducts: 1,
      hasCrCard: true,
      isActiveMember: true,
      estimatedSalary: 50000.0,
    );
  }

  CustomerEntity copyWith({
    String? surname,
    int? creditScore,
    String? geography,
    String? gender,
    int? age,
    int? tenure,
    double? balance,
    int? numOfProducts,
    bool? hasCrCard,
    bool? isActiveMember,
    double? estimatedSalary,
    double? churnProbability,
  }) {
    return CustomerEntity(
      surname: surname ?? this.surname,
      creditScore: creditScore ?? this.creditScore,
      geography: geography ?? this.geography,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      tenure: tenure ?? this.tenure,
      balance: balance ?? this.balance,
      numOfProducts: numOfProducts ?? this.numOfProducts,
      hasCrCard: hasCrCard ?? this.hasCrCard,
      isActiveMember: isActiveMember ?? this.isActiveMember,
      estimatedSalary: estimatedSalary ?? this.estimatedSalary,
      churnProbability: churnProbability ?? this.churnProbability,
    );
  }
}
