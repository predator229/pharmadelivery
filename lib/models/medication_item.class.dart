class MedicationItem {
  String id;
  String name;
  int quantity;
  double price;

  MedicationItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.price,
  });

  factory MedicationItem.fromJson(Map<String, dynamic> json) {
    return MedicationItem(
      id: json['_id'],
      name: json['name'],
      quantity: json['quantity'],
      price: json['price'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'price': price,
    };
  }
}