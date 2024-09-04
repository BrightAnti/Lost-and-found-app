// lib/models/pickup_point.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class PickupPoint {
  final String id;
  final String name;
  final String location;

  PickupPoint({
    required this.id,
    required this.name,
    required this.location,
  });

  factory PickupPoint.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PickupPoint(
      id: doc.id,
      name: data['name'] ?? '',
      location: data['location'] ?? '',
    );
  }
}
