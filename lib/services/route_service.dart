import 'package:cloud_firestore/cloud_firestore.dart';

class RouteService {
  Future<List<String>> getStops() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('routes')
        .get();

    final stops = <String>{};

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final stopOrder = List<String>.from(data['stop_order'] ?? []);
      stops.addAll(stopOrder);
    }

    return stops.toList();
  }

  Future<String?> getRouteIdByStops(String from, String to) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('routes')
        .get();

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final stopOrder = List<String>.from(data['stop_order'] ?? []);

      if (stopOrder.contains(from) && stopOrder.contains(to)) {
        final fromIndex = stopOrder.indexOf(from);
        final toIndex = stopOrder.indexOf(to);

        if (fromIndex < toIndex) {
          return doc.id;
        }
      }
    }
    return null;
  }

  // Get the ordered stops of a specific route.
  Future<List<String>> getRouteStops(String routeId) async {
    // Get the route document using its ID.
    final doc = await FirebaseFirestore.instance
        .collection('routes')
        .doc(routeId)
        .get();

    // Get the route data.
    final data = doc.data();

    // Return an empty list of the route does not exist.
    if (data == null) {
      return [];
    }

    // Get and return the orderd stops.
    return List<String>.from(data['stop_order'] ?? []);
  }
}
