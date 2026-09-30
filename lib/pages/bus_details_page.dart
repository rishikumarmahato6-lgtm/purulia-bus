import 'package:flutter/material.dart';
import '../models/bus.dart';
import '../theme/app_theme.dart';

// A top-level function (outside any class) that both the tiles and the
// stops card use. The white rounded card with a soft shadow is written once
// here, so every card on this page looks identical.
BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(18),
    boxShadow: const [
      BoxShadow(
        color: Color(0x0F000000), // black at about 6% opacity
        blurRadius: 12,
        offset: Offset(0, 4),
      ),
    ],
  );
}

// StatelessWidget: this page only shows the bus it receives, nothing changes.
class BusDetailsPage extends StatelessWidget {
  final Bus bus; // the bus the user tapped on the results list

  const BusDetailsPage({super.key, required this.bus});

  @override
  Widget build(BuildContext context) {
    // Many buses have '---' as arrival because it is unknown.
    // Only treat it as a real time when it has a real value.
    final hasArrival =
        bus.arrival.trim().isNotEmpty && !bus.arrival.contains('--');

    return Scaffold(
      // Color and style of the app bar come from our theme.
      appBar: AppBar(title: const Text('Bus Details')),

      // SingleChildScrollView lets the whole page scroll on small screens.
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),

            // ---------- Row 1: departure and arrival ----------
            // Expanded on both tiles makes them share the width equally.
            Row(
              children: [
                Expanded(
                  child: _InfoTile(
                    icon: Icons.access_time,
                    iconColor: AppColors.blue,
                    label: 'Departure',
                    value: bus.departure,
                    note: 'from ${bus.from}',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InfoTile(
                    icon: Icons.flag_outlined,
                    iconColor: AppColors.orange,
                    label: 'Arrival',
                    value: hasArrival ? bus.arrival : 'Not available',
                    note: hasArrival ? 'at ${bus.to}' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ---------- Row 2: fare and total stops ----------
            Row(
              children: [
                Expanded(
                  child: _InfoTile(
                    icon: Icons.currency_rupee,
                    iconColor: AppColors.green,
                    label: 'Fare',
                    value:
                        '₹${bus.fare.toStringAsFixed(0)}', // 30.0 becomes ₹30
                    note: 'Approx.',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InfoTile(
                    icon: Icons.route,
                    iconColor: AppColors.navy,
                    label: 'Total Stops',
                    value: '${bus.stops.length}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            _buildStopsCard(),
            const SizedBox(height: 16),

            _buildNotice(),
          ],
        ),
      ),
    );
  }

  // ---------- Header card: bus icon, name, journey ----------
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.blue.withAlpha(31), // see-through blue
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.directions_bus,
              color: AppColors.blue,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          // Expanded so a long bus name wraps instead of overflowing.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bus.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${bus.from} → ${bus.to}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Bus stops card with the timeline ----------
  Widget _buildStopsCard() {
    return Container(
      width: double.infinity, // stretch the card to the full width
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bus Stops',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 18),

          // asMap().entries gives us both the position (index) and the stop
          // name, because we need the index to know if a stop is first or last.
          // The three dots (...) spread the resulting widgets into the Column.
          ...bus.stops.asMap().entries.map((entry) {
            final index = entry.key;
            final stopName = entry.value;
            final isFirst = index == 0;
            final isLast = index == bus.stops.length - 1;

            // First stop = green, last stop = red, stops in between = navy.
            final dotColor = isFirst
                ? AppColors.green
                : isLast
                ? Colors.red
                : AppColors.navy;

            // IntrinsicHeight makes the dot column as tall as the text row,
            // so the vertical line can stretch to reach the next dot.
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Left part: the dot and the line below it.
                  SizedBox(
                    width: 24,
                    child: Column(
                      children: [
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: dotColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        // The last stop has no line below it.
                        if (!isLast)
                          Expanded(
                            child: Container(
                              width: 2,
                              color: const Color(0xFFCBD5E1), // light grey line
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Right part: the stop name. Bottom padding makes the gap
                  // between stops (and so the length of the line).
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: isLast ? 0 : 22),
                      child: Text(
                        stopName,
                        style: TextStyle(
                          fontSize: 16,
                          // First and last stops are bold so they stand out.
                          fontWeight: (isFirst || isLast)
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ---------- Yellow notice at the bottom ----------
  Widget _buildNotice() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6DD), // light yellow
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        children: [
          Icon(Icons.info, color: AppColors.orange),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Timings may vary depending on traffic and local conditions.',
              style: TextStyle(fontSize: 13, color: AppColors.textDark),
            ),
          ),
        ],
      ),
    );
  }
}

// A small reusable box: icon + label on top, value below, optional note.
// We use it four times (departure, arrival, fare, stops), so we write it once.
class _InfoTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String? note; // the ? means this is optional and can be null

  const _InfoTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.note,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top line: small icon and the label.
          Row(
            children: [
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // The main value, in big bold text.
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          // "if (note != null)" shows this Text only when a note was given.
          if (note != null) ...[
            const SizedBox(height: 2),
            Text(
              note!, // the ! tells Dart "I checked, it is not null"
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ],
        ],
      ),
    );
  }
}
