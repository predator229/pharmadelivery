import 'medication_item.class.dart';

class MedicationOrder {
  String id;
  String customerId;
  String pharmacyId;
  List<MedicationItem> items;
  double totalPrice;
  String status; // e.g., "Pending", "In Progress", "Delivered", "Cancelled"
  DateTime orderDate;
  DateTime? deliveryDate;
  String deliveryAddress;
  String? deliveryPersonId;

  MedicationOrder({
    required this.id,
    required this.customerId,
    required this.pharmacyId,
    required this.items,
    required this.totalPrice,
    required this.status,
    required this.orderDate,
    this.deliveryDate,
    required this.deliveryAddress,
    this.deliveryPersonId,
  });

  factory MedicationOrder.fromJson(Map<String, dynamic> json) {
    return MedicationOrder(
      id: json['_id'],
      customerId: json['customerId'],
      pharmacyId: json['pharmacyId'],
      items: (json['items'] as List)
          .map((item) => MedicationItem.fromJson(item))
          .toList(),
      totalPrice: json['totalPrice'].toDouble(),
      status: json['status'],
      orderDate: DateTime.parse(json['orderDate']),
      deliveryDate: json['deliveryDate'] != null
          ? DateTime.parse(json['deliveryDate'])
          : null,
      deliveryAddress: json['deliveryAddress'],
      deliveryPersonId: json['deliveryPersonId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'customerId': customerId,
      'pharmacyId': pharmacyId,
      'items': items.map((item) => item.toJson()).toList(),
      'totalPrice': totalPrice,
      'status': status,
      'orderDate': orderDate.toIso8601String(),
      'deliveryDate': deliveryDate?.toIso8601String(),
      'deliveryAddress': deliveryAddress,
      'deliveryPersonId': deliveryPersonId,
    };
  }
}