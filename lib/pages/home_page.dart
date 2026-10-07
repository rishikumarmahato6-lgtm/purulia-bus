import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // gives us SystemUiOverlayStyle (status bar icon color)
import '../theme/app_theme.dart';
import 'search_page.dart';

// StatelessWidget: the home page only displays things, nothing changes on it.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // Opens the search page. We write it once because two places use it.
  void _openSearch(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SearchPage()),
    );
  }

  // Shows a small message at the bottom of the screen (a SnackBar).
  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$feature is coming soon')));
  }

  // NEW: Shows a popup explaining that this app is NOT an official
  // government app. Google wants this disclaimer to be easy to see.
  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('About Purulia Bus'), // popup heading
        content: const Text(
          'Purulia Bus is an independent, unofficial app. It is NOT a '
          'government app and does not represent any government entity '
          'or bus operator.\n\n'
          'Timings are approximate and may be out of date. Please verify '
          'at the bus stand before you travel.',
        ),
        actions: [
          // Closes the popup when pressed
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AnnotatedRegion makes the phone's status bar icons (time, battery)
      // white, so they are visible on top of our dark header.
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        // The whole page scrolls, so it also works on small phones.
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------- Top part: the header with the hills ----------
              _buildHero(),

              // ---------- Rest of the page, with space around it ----------
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ----- First row of cards -----
                    // Expanded makes the two cards share the width equally.
                    Row(
                      children: [
                        Expanded(
                          child: _CategoryCard(
                            icon: Icons.directions_bus,
                            title: 'Local',
                            subtitle: 'Buses within\nPurulia district',
                            colors: const [AppColors.blue, AppColors.navy],
                            onTap: () => _openSearch(context),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _CategoryCard(
                            icon: Icons.directions_bus_filled,
                            title: 'Intercity',
                            subtitle: 'Kolkata, Dhanbad\n& beyond',
                            colors: const [
                              Color(0xFF9B6BFF),
                              Color(0xFF5B3FD0),
                            ],
                            enabled:
                                false, // dimmed, with a "Coming soon" badge
                            onTap: () => _showComingSoon(context, 'Intercity'),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // ----- Second row of cards -----
                    Row(
                      children: [
                        Expanded(
                          // CHANGED: the old "Govt. Bus" card (SBSTC & WBTC)
                          // is now an "About" card. Google rejected the app
                          // because the old card looked like an official
                          // government service.
                          child: _CategoryCard(
                            icon: Icons.info_outline, // "i" icon
                            title: 'About',
                            subtitle: 'Unofficial app &\ndata source',
                            colors: const [AppColors.green, Color(0xFF13803F)],
                            // enabled stays true (the default), so this card
                            // works and has no "Coming soon" badge.
                            onTap: () => _showAbout(context), // opens popup
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _CategoryCard(
                            icon: Icons.place,
                            title: 'Search Route',
                            subtitle: 'Find any route\nby stops',
                            colors: const [AppColors.orange, Color(0xFFE0621A)],
                            enabled: false,
                            onTap: () =>
                                _showComingSoon(context, 'Search Route'),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    const Text(
                      'Available Routes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),

                    _buildRouteTile(context),

                    const SizedBox(height: 28),

                    // NEW: the second photo, a wide banner with a short slogan.
                    _buildBanner(),

                    const SizedBox(height: 20),

                    // CHANGED: the footer now also says the app is unofficial.
                    const Center(
                      child: Text(
                        'Unofficial app. Not affiliated with any government '
                        'body or bus operator. Times are approximate. '
                        'Verify at the bus stand before travel.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- Header: sky gradient, sun, hills and the title ----------
  Widget _buildHero() {
    // ClipRRect cuts everything inside it to a shape with rounded corners.
    // Without it, the hills would stick out over the rounded bottom corners.
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(32),
        bottomRight: Radius.circular(32),
      ),
      child: Container(
        width: double.infinity, // full width of the screen
        // The sky: a gradient from dark navy (top) to blue (bottom).
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.navy, Color(0xFF4A90D9)],
          ),
        ),
        // Stack puts widgets on top of each other. The first child is at the
        // back, the last child is at the front.
        child: Stack(
          children: [
            // 1. The sun: a soft warm circle in the sky (at the very back).
            Positioned(
              right: 32,
              top: 70,
              child: Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Color(0x55FFD9A0), // warm yellow, mostly see-through
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // 2. The hills: pinned to the bottom edge, 110 pixels tall.
            // CustomPaint runs our _HillsPainter class to draw them.
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 110,
              child: CustomPaint(painter: _HillsPainter()),
            ),

            // NEW: 2b. The header photo. Positioned.fill stretches it over the
            // whole header. BoxFit.cover crops it so it never looks squashed.
            // errorBuilder runs if the picture file is missing, and we show
            // nothing, so the gradient and hills above stay visible instead
            // of the app crashing.
            Positioned.fill(
              child: Image.asset(
                'assets/images/header_bg.jpg',
                fit: BoxFit.cover,
                // TEMPORARY: prints the real error on the screen.
                // Change back to SizedBox.shrink() once the photo loads.
                errorBuilder: (context, error, stackTrace) => Text(
                  '$error',
                  style: const TextStyle(color: Colors.yellow, fontSize: 11),
                ),
              ),
            ),
            // NEW: 2c. A dark tint on top of the photo so the white text is
            // easy to read. It is darker at the top and lighter at the bottom.
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    // 0xCC = mostly dark, 0x33 = mostly see-through
                    colors: [Color(0xCC0D3B6E), Color(0x330D3B6E)],
                  ),
                ),
              ),
            ),

            // 3. The text (at the front). This is the only child that is not
            // Positioned, so its size decides the height of the whole header.
            // The big bottom padding leaves room for the hills below the text.
            SafeArea(
              bottom: false, // SafeArea only protects the top (status bar)
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // CHANGED: the old Bengali text sounded like an official
                    // timetable. This one says "Purulia Bus Guide (Unofficial)".
                    const Text(
                      'পুরুলিয়া বাস গাইড (অনানুষ্ঠানিক)',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Purulia Bus',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Your Local Travel Partner',
                      style: TextStyle(color: Colors.white70, fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- NEW: wide photo banner with a short slogan ----------
  Widget _buildBanner() {
    // ClipRRect rounds the corners of the photo.
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        width: double.infinity,
        height: 150, // banner height in pixels
        child: Stack(
          children: [
            // The photo. If the file is missing, a green gradient is shown.
            Positioned.fill(
              child: Image.asset(
                'assets/images/banner.jpg', // your second photo
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.green, Color(0xFF13803F)],
                    ),
                  ),
                ),
              ),
            ),

            // Dark tint at the bottom so the text is readable.
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x00000000), Color(0xAA000000)],
                  ),
                ),
              ),
            ),

            // The slogan, pinned to the bottom-left corner.
            const Positioned(
              left: 16,
              bottom: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Explore Purulia',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Know your bus timings before you go',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Tile that shows the route we currently cover ----------
  Widget _buildRouteTile(BuildContext context) {
    return Container(
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
      // Material + InkWell = the tap ripple effect.
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _openSearch(context),
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.route, color: AppColors.blue),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Purulia → Manbazar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Tap to search buses',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: AppColors.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// A CustomPainter draws shapes directly on a canvas, like a pencil.
// We draw three layers of hills: the back layer first, the front layer last,
// so the front hills cover the back ones and it looks like real depth.
class _HillsPainter extends CustomPainter {
  const _HillsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width; // width of the drawing area
    final h = size.height; // height of the drawing area

    // ----- Back hills: lightest color, tallest peaks -----
    // A Path is a line we draw point by point.
    // quadraticBezierTo(controlX, controlY, endX, endY) draws a smooth curve
    // that bends towards the control point and ends at the end point.
    final back = Path()
      ..moveTo(0, h * 0.55) // start on the left edge
      ..quadraticBezierTo(w * 0.25, h * 0.05, w * 0.5, h * 0.5) // first hill
      ..quadraticBezierTo(w * 0.75, h * 0.95, w, h * 0.35) // second hill
      ..lineTo(w, h) // down the right edge
      ..lineTo(0, h) // along the bottom
      ..close(); // back to the start, so the shape can be filled
    canvas.drawPath(back, Paint()..color = const Color(0xFF3FA08F));

    // ----- Middle hills: a darker green -----
    final middle = Path()
      ..moveTo(0, h * 0.8)
      ..quadraticBezierTo(w * 0.3, h * 0.3, w * 0.6, h * 0.7)
      ..quadraticBezierTo(w * 0.85, h * 1.0, w, h * 0.55)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(middle, Paint()..color = const Color(0xFF238363));

    // ----- Front hills: the darkest green, closest to the viewer -----
    final front = Path()
      ..moveTo(0, h * 0.92)
      ..quadraticBezierTo(w * 0.5, h * 0.55, w, h * 0.9)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(front, Paint()..color = const Color(0xFF15583F));
  }

  // The hills never change, so Flutter never needs to redraw them.
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// A reusable colored card (used for all four categories).
class _CategoryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> colors; // the two colors of the gradient
  final bool enabled; // false = dimmed with a "Coming soon" badge
  final VoidCallback onTap;

  const _CategoryCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.colors,
    required this.onTap,
    this.enabled = true, // default: cards are enabled unless we say otherwise
  });

  @override
  Widget build(BuildContext context) {
    // A fixed height is needed because we use Spacer() inside the card.
    return SizedBox(
      height: 170,
      // Opacity makes the whole card see-through when it is disabled.
      child: Opacity(
        opacity: enabled ? 1 : 0.7,
        child: Material(
          color: Colors.transparent,
          // Ink draws the gradient in a way that the tap ripple stays
          // visible above it.
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: colors,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Round see-through circle behind the icon.
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Colors.white24,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: Colors.white, size: 24),
                    ),
                    // Spacer pushes everything below it to the bottom.
                    const Spacer(),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    // Show the badge only when the card is disabled.
                    if (!enabled) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Coming soon',
                          style: TextStyle(color: Colors.white, fontSize: 11),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
