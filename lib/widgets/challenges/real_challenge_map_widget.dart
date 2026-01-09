import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class RealChallengeMapWidget extends StatefulWidget {
  final double progress;
  final String? avatarUrl;
  final LatLng initialCenter;
  final double height;

  const RealChallengeMapWidget({
    super.key,
    required this.progress,
    this.avatarUrl,
    this.initialCenter = const LatLng(6.9271, 79.8612), // Colombo, Sri Lanka
    this.height = 300,
  });

  @override
  State<RealChallengeMapWidget> createState() => _RealChallengeMapWidgetState();
}

class _RealChallengeMapWidgetState extends State<RealChallengeMapWidget> {
  final MapController _mapController = MapController();
  bool _isSatellite = false;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // Determine Tile Layer URL
    String urlTemplate = isDark
        ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
        : 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png';

    if (_isSatellite) {
      urlTemplate =
          'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
    }

    return Container(
      height: widget.height,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: widget.initialCenter,
                initialZoom: 13.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: urlTemplate,
                  subdomains: const ['a', 'b', 'c', 'd'],
                  userAgentPackageName: 'com.powerhouse.app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: widget.initialCenter,
                      width: 80,
                      height: 100,
                      child: _buildCustomMarker(context),
                    ),
                  ],
                ),
              ],
            ),

            // Top HUD Overlay
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildRoundButton(
                    icon: Icons.close,
                    onTap: () => Navigator.maybePop(context),
                  ),
                  Text(
                    'Location',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      shadows: [
                        Shadow(
                          color: isDark
                              ? Colors.black.withOpacity(0.5)
                              : Colors.white.withOpacity(0.5),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  _buildRoundButton(
                    icon: Icons.search,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Search feature coming soon!'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Bottom Right Controls
            Positioned(
              bottom: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                decoration: BoxDecoration(
                  color: (isDark ? const Color(0xFF2D2D2D) : Colors.white)
                      .withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: (isDark ? Colors.white : Colors.black).withOpacity(
                      0.1,
                    ),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildControlButton(
                      icon: Icons.map_outlined,
                      onTap: () {
                        setState(() {
                          _isSatellite = !_isSatellite;
                        });
                      },
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    const SizedBox(height: 16),
                    _buildControlButton(
                      icon: Icons.navigation_outlined,
                      onTap: () {
                        _mapController.move(widget.initialCenter, 15.0);
                      },
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ],
                ),
              ),
            ),

            // Gradient Fades
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 60,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      (isDark ? Colors.black : Colors.white).withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoundButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: (isDark ? const Color(0xFF2D2D2D) : Colors.white).withOpacity(
            0.8,
          ),
          shape: BoxShape.circle,
          border: Border.all(
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5),
          ],
        ),
        child: Icon(
          icon,
          color: isDark ? Colors.white : Colors.black87,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, color: color.withOpacity(0.8), size: 24),
    );
  }

  Widget _buildCustomMarker(BuildContext context) {
    return Column(
      children: [
        // Avatar with border
        Container(
          width: 55,
          height: 55,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(
            child: widget.avatarUrl != null && widget.avatarUrl!.isNotEmpty
                ? Image.network(
                    widget.avatarUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
                  )
                : _buildDefaultAvatar(),
          ),
        ),
        // Pointer triangle
        CustomPaint(size: const Size(12, 8), painter: _TrianglePainter()),
        // Blue dot at the point
        Container(
          width: 15,
          height: 15,
          decoration: BoxDecoration(
            color: const Color(0xFF2196F3),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2196F3).withOpacity(0.5),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: const Color(0xFF1DAB87),
      child: const Icon(Icons.person, color: Colors.white, size: 30),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = ui.Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width / 2, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
