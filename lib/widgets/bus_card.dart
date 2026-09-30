import 'package:flutter/material.dart';
import '../models/bus.dart';
import '../theme/app_theme.dart';

// A StatelessWidget = a piece of UI that only displays data it receives.
// It never changes by itself, so it doesn't need a State class.
class BusCard extends StatelessWidget {
  final Bus bus; // the bus this card displays
  final int colorIndex; // used to give each card a different icon color
  final VoidCallback onTap; // VoidCallback = "a function to run on tap".
  // The parent page decides what happens, the card just reports the tap.

  const BusCard({
    super.key,
    required this.bus,
    required this.colorIndex,
    required this.onTap,
  });

  // static const = one shared list for all cards, not created again for each card.
  static const List<Color> _iconColors = [
    AppColors.blue,
    Color(0xFF7C4DFF), // purple
    AppColors.green,
    AppColors.orange,
  ];

  @override
  Widget build(BuildContext context) {
    // % (modulo) cycles through the list: index 0,1,2,3,4 -> colors 0,1,2,3,0
    final iconColor = _iconColors[colorIndex % _iconColors.length];

    // Many of your buses have arrival '---' because it is unknown.
    // Only show the arrival time when there is a real value.
    final hasArrival =
        bus.arrival.trim().isNotEmpty && !bus.arrival.contains('--');
    final timeText = hasArrival
        ? '${bus.departure}  →  ${bus.arrival}'
        : 'Departs ${bus.departure}';

    // The Container draws the white rounded card and its shadow.
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      // Material + InkWell gives the ripple effect when the card is tapped.
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(
            18,
          ), // ripple follows the rounded corners
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---------- Top row: icon, name, arrow ----------
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        // withAlpha makes the color see-through (0 to 255).
                        color: iconColor.withAlpha(31),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.directions_bus, color: iconColor),
                    ),
                    const SizedBox(width: 12),
                    // Expanded lets the text take the remaining width,
                    // so long names get "..." instead of an overflow error.
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bus.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${bus.from} → ${bus.to}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.textMuted),
                  ],
                ),

                const SizedBox(height: 14),

                // ---------- Time row ----------
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 18,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      timeText,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // ---------- Fare and stops row ----------
                Row(
                  children: [
                    const Icon(
                      Icons.currency_rupee,
                      size: 18,
                      color: AppColors.green,
                    ),
                    Text(
                      bus.fare.toStringAsFixed(0), // 30.0 becomes "30"
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.green,
                      ),
                    ),
                    const SizedBox(width: 20),
                    const Icon(
                      Icons.route,
                      size: 18,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${bus.stops.length} stops',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
