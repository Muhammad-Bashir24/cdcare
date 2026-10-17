class Products {
  const Products({
    required this.name,
    required this.price,
    required this.installmentAmount,
    required this.installmentDurationMonths,
  });

  final String name;
  final double price;
  final double installmentAmount;
  final int installmentDurationMonths;
}
