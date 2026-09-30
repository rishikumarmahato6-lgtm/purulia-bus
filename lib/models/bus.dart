class Bus {
  final String name;
  final String departure;
  final String arrival;
  final String from;
  final String to;
  final double fare;
  final List<String> stops;

  const Bus({
    required this.name,
    required this.departure,
    required this.arrival,
    required this.from,
    required this.to,
    required this.fare,
    required this.stops,
  });
}
