class DoctorService {
  final String id;
  final String name;
  final String description;
  final double price;

  DoctorService({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
  });

  factory DoctorService.fromJson(Map<String, dynamic> json) {
    return DoctorService(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      price: (json['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
    };
  }
}
