import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/bus.dart';

class BusService {
  Future<List<Bus>> getBusesByRoute(
    String routeId,
    List<String> selectedStops,
  ) async {
    // Get buses that belong to the selected route.
    final snapshot = await FirebaseFirestore.instance
        .collection('buses')
        .where('routeID', isEqualTo: routeId)
        .get();

    // Convert each Firestore document into a Bus object.
    return snapshot.docs.map((doc) {
      final data = doc.data();

      return Bus(
        name: data['name'] ?? '',
        departure: data['departure'] ?? '',
        arrival: data['arrival'] ?? '',
        from: data['from'] ?? '',
        to: data['to'] ?? '',
        fare: (data['fare'] ?? 0).toDouble(),
        stops: selectedStops,
      );
    }).toList();
  }
}
