import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../config/theme/app_theme.dart';
import '../../data/navigation_service.dart';

class RouteSummaryPage extends StatefulWidget {
  final Map<String, dynamic> routeData;
  final List<String> initialProducts;
  final double userLat;
  final double userLng;

  const RouteSummaryPage({
    super.key,
    required this.routeData,
    required this.initialProducts,
    required this.userLat,
    required this.userLng,
  });

  @override
  State<RouteSummaryPage> createState() => _RouteSummaryPageState();
}

class _RouteSummaryPageState extends State<RouteSummaryPage> {
  final NavigationService _navigationService = NavigationService();
  final TextEditingController _chatController = TextEditingController();

  late Map<String, dynamic> _currentRoute;
  final List<Map<String, dynamic>> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _currentRoute = widget.routeData;
    _addSystemMessage(
      "I've optimized your route! 🚗\n"
      "Total Distance: ${(_currentRoute['total_distance'] / 1000).toStringAsFixed(1)} km\n"
      "Est. Time: ${(_currentRoute['total_time'] / 60).toStringAsFixed(0)} mins\n\n"
      "Let me know if you want to change anything!",
    );
  }

  void _addSystemMessage(String content) {
    setState(() {
      _messages.add({
        'role': 'assistant',
        'content': content,
        'timestamp': DateTime.now(),
      });
    });
  }

  Future<void> _sendMessage() async {
    if (_chatController.text.trim().isEmpty) return;

    final userMsg = _chatController.text.trim();
    _chatController.clear();

    setState(() {
      _messages.add({
        'role': 'user',
        'content': userMsg,
        'timestamp': DateTime.now(),
      });
      _isTyping = true;
    });

    try {
      // Build history for context
      final history = _messages
          .map(
            (m) => {
              'role': m['role'] as String,
              'content': m['content'] as String,
            },
          )
          .toList();

      final response = await _navigationService.chatWithAI(
        message: userMsg,
        latitude: widget.userLat,
        longitude: widget.userLng,
        history: history,
      );

      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add({
            'role': 'assistant',
            'content': response['response'],
            'timestamp': DateTime.now(),
          });

          // Check if route was updated
          if (response['type'] == 'route' && response['data'] != null) {
            _currentRoute = response['data'];
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _addSystemMessage(
            "Sorry, I had trouble connecting. Please try again.",
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Parse Polyline
    final points = (_currentRoute['polyline'] as List)
        .map((p) => LatLng(p[0] as double, p[1] as double))
        .toList();

    // Parse Markers (Stops)
    final stops = _currentRoute['stops'] as List;
    final markers = stops.map((stop) {
      final loc = stop['store']['location'];
      return Marker(
        point: LatLng(loc['latitude'], loc['longitude']),
        width: 40,
        height: 40,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: AppTheme.shadowSm,
          ),
          child: Center(
            child: Text(
              '${stop['order']}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }).toList();

    // Add User Marker
    markers.add(
      Marker(
        point: LatLng(widget.userLat, widget.userLng),
        width: 40,
        height: 40,
        child: const Icon(Icons.my_location, color: AppColors.accent, size: 30),
      ),
    );

    return Scaffold(
      body: Stack(
        children: [
          // Map Layer
          FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(widget.userLat, widget.userLng),
              initialZoom: 13,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.shoproute.app',
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: points,
                    color: AppColors.primary,
                    strokeWidth: 4,
                  ),
                ],
              ),
              MarkerLayer(markers: markers),
            ],
          ),

          // Back Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => context.pop(),
              ),
            ),
          ),

          // Bottom Sheet (AI Chat & Route Steps)
          DraggableScrollableSheet(
            initialChildSize: 0.45,
            minChildSize: 0.2,
            maxChildSize: 0.8,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  boxShadow: AppTheme.shadowMd,
                ),
                child: Column(
                  children: [
                    // Handle
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    // Tabs or Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Text(
                            "Your Trip",
                            style: AppTextStyles.headlineSmall(),
                          ),
                          const Spacer(),
                          Text(
                            "${stops.length} Stops • ${(_currentRoute['total_distance'] / 1000).toStringAsFixed(1)}km",
                            style: AppTextStyles.bodySmall(),
                          ),
                        ],
                      ),
                    ),
                    const Divider(),

                    // Chat / List View
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount:
                            _messages.length + 1, // +1 for Typing indicator
                        itemBuilder: (context, index) {
                          if (index == _messages.length) {
                            return _isTyping
                                ? const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      "AI is thinking...",
                                      style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink();
                          }

                          final msg = _messages[index];
                          final isUser = msg['role'] == 'user';

                          return Align(
                            alignment: isUser
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isUser
                                    ? AppColors.primary
                                    : Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                msg['content'],
                                style: TextStyle(
                                  color: isUser ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Input Area
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _chatController,
                              decoration: InputDecoration(
                                hintText: "Change route (e.g. 'Use QuickShop')",
                                filled: true,
                                fillColor: Colors.grey[100],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                              ),
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          CircleAvatar(
                            backgroundColor: AppColors.primary,
                            child: IconButton(
                              icon: const Icon(
                                Icons.send,
                                color: Colors.white,
                                size: 20,
                              ),
                              onPressed: _sendMessage,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
