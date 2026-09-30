import 'package:flutter/material.dart';
import '../models/bus.dart';
import '../services/bus_service.dart';
import '../services/route_service.dart';
import '../theme/app_theme.dart';
import '../widgets/bus_card.dart';
import 'bus_details_page.dart';

// StatefulWidget = a page whose content changes (dropdown values, results...).
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

// This class holds the changing data (state) of the page and builds its UI.
class _SearchPageState extends State<SearchPage> {
  // Create the services once and reuse them for every search.
  final RouteService _routeService = RouteService();
  final BusService _busService = BusService();

  List<String> stops = []; // all stops, used to fill both dropdowns
  List<Bus> buses = []; // buses found by the last search
  String? selectedFrom; // null means "not chosen yet"
  String? selectedTo;

  bool isLoading = false; // true while we wait for Firebase
  String? message; // shown when something goes wrong or nothing is found

  // We save the "From → To" text at search time, so the heading stays
  // correct even if the user changes a dropdown afterwards.
  String resultTitle = '';
  // true when loading the stops from Firebase failed (e.g. no internet).
  bool stopsFailed = false;

  // Runs once when the page opens.
  @override
  void initState() {
    super.initState();
    loadStops();
  }

  // Loads the stop names from Firebase to fill the dropdowns.
  Future<void> loadStops() async {
    // try/catch: if anything fails (no internet, Firebase down), the app
    // catches the error and shows a Retry button instead of staying silent.
    try {
      // .timeout stops waiting after 10 seconds instead of waiting forever.
      final loadedStops = await _routeService.getStops().timeout(
        const Duration(seconds: 10),
      );

      // If the user left the page while we were waiting, don't touch the screen.
      if (!mounted) return;

      setState(() {
        stops = loadedStops;
        stopsFailed = false; // it worked, so hide the error
      });
    } catch (e) {
      debugPrint('Load stops error: $e');
      if (!mounted) return;
      setState(() => stopsFailed = true);
    }
  }

  // Converts a time like "05:45 A.M" or "01:20 P.M" into minutes after
  // midnight, so we can sort buses by time.
  int _timeToMinutes(String time) {
    // Make the text consistent: uppercase, and remove dots ("A.M" -> "AM").
    final cleaned = time.toUpperCase().replaceAll('.', '');

    // RegExp finds the pattern: hour, colon, minutes, then A or P.
    final match = RegExp(r'(\d{1,2}):(\d{2})\s*([AP])').firstMatch(cleaned);

    // If a time can't be read (e.g. "07:20" with no AM/PM), send it to the end.
    if (match == null) return 99999;

    final hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    final isPm = match.group(3) == 'P';

    // 12 AM is hour 0, 12 PM stays 12, other PM hours add 12.
    return (hour % 12 + (isPm ? 12 : 0)) * 60 + minute;
  }

  // Runs when the user presses "Search Buses".
  Future<void> searchBuses() async {
    // 1. Make sure both stops are chosen.
    if (selectedFrom == null || selectedTo == null) {
      setState(() => message = 'Please choose both From and To');
      return;
    }

    // 2. Show the spinner and clear the previous results.
    setState(() {
      isLoading = true;
      message = null;
      buses = [];
    });

    // try/catch/finally: if the internet fails, the app shows a message
    // instead of freezing. "finally" always runs, so the spinner always stops.
    try {
      // 3. Find the route that contains both stops.
      final routeId = await _routeService.getRouteIdByStops(
        selectedFrom!,
        selectedTo!,
      );
      if (!mounted) return;

      if (routeId == null) {
        setState(
          () => message = 'No route found from $selectedFrom to $selectedTo',
        );
        return;
      }

      // 4. Get the ordered stops and check the direction of travel.
      final routeStops = await _routeService.getRouteStops(routeId);
      final fromIndex = routeStops.indexOf(selectedFrom!);
      final toIndex = routeStops.indexOf(selectedTo!);

      if (fromIndex >= toIndex) {
        setState(() => message = 'Please choose the stops in travel order');
        return;
      }

      // 5. Keep only the stops between From and To (inclusive).
      final selectedStops = routeStops.sublist(fromIndex, toIndex + 1);

      // 6. Fetch the buses of this route.
      final fetchedBuses = await _busService.getBusesByRoute(
        routeId,
        selectedStops,
      );
      if (!mounted) return;

      // 7. Sort earliest bus first. compareTo returns negative / zero /
      // positive, and sort() uses that to decide the order.
      fetchedBuses.sort(
        (a, b) =>
            _timeToMinutes(a.departure).compareTo(_timeToMinutes(b.departure)),
      );

      setState(() {
        buses = fetchedBuses;
        resultTitle = '$selectedFrom → $selectedTo';
        if (fetchedBuses.isEmpty) {
          message = 'No buses found for this route yet';
        }
      });
    } catch (e) {
      debugPrint('Search error: $e');
      if (mounted) {
        setState(() => message = 'Something went wrong. Check your internet.');
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // build() creates the UI of the page.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Color and style come from our theme, so no styling code is needed here.
      appBar: AppBar(title: const Text('Local Bus')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // "if (...) Widget" shows the widget only when the
              // condition is true. This row appears only after a failure.
              if (stopsFailed)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Row(
                    children: [
                      const Icon(Icons.wifi_off, color: Colors.red),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Could not load stops. Check your internet.',
                          style: TextStyle(color: AppColors.textDark),
                        ),
                      ),
                      // Tapping Retry runs loadStops() again.
                      TextButton(
                        onPressed: loadStops,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),

              _StopDropdown(
                label: 'From',
                icon: Icons.trip_origin,
                iconColor: AppColors.green,
                stops: stops,
                onChanged: (value) => setState(() => selectedFrom = value),
              ),
              const SizedBox(height: 14),
              _StopDropdown(
                label: 'To',
                icon: Icons.location_on,
                iconColor: Colors.red,
                stops: stops,
                onChanged: (value) => setState(() => selectedTo = value),
              ),
              const SizedBox(height: 18),

              // onPressed: null disables the button while loading,
              // which stops the user from tapping it twice.
              ElevatedButton.icon(
                onPressed: isLoading ? null : searchBuses,
                icon: const Icon(Icons.search),
                label: const Text('Search Buses'),
              ),
              const SizedBox(height: 20),

              // Expanded = use all the remaining height for the results.
              Expanded(child: _buildResults()),
            ],
          ),
        ),
      ),
    );
  }

  // Decides what to show under the form: spinner, message, list, or nothing.
  Widget _buildResults() {
    // Show a spinner while Firebase is loading.
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Show a message such as "No buses found".
    if (message != null) {
      return Center(
        child: Text(
          message!,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 15),
        ),
      );
    }

    // Nothing searched yet.
    if (buses.isEmpty) return const SizedBox.shrink();

    // Heading + list. A Column stacks them vertically.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          resultTitle,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${buses.length} buses found',
          style: const TextStyle(color: AppColors.textMuted),
        ),
        const SizedBox(height: 14),

        // Expanded makes the ListView take the remaining height and
        // scroll inside it.
        Expanded(
          child: ListView.builder(
            itemCount: buses.length,
            itemBuilder: (context, index) {
              final bus = buses[index];
              return BusCard(
                bus: bus,
                colorIndex: index,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => BusDetailsPage(bus: bus)),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
} // <- this closes _SearchPageState

// A small reusable widget. From and To look identical, so we write the
// dropdown once and use it twice with different labels and icons.
// The leading underscore makes it private to this file.
class _StopDropdown extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  final List<String> stops;
  final ValueChanged<String?> onChanged;

  const _StopDropdown({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.stops,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      isExpanded: true, // prevents overflow errors on long stop names
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: iconColor),
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none, // no outline, only the filled background
        ),
      ),
      // Turn each stop name into a dropdown row.
      items: stops
          .map((stop) => DropdownMenuItem(value: stop, child: Text(stop)))
          .toList(),
      onChanged: onChanged,
    );
  }
} // <- last line of the file. Nothing goes after this.
