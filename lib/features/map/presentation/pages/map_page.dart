import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../config/theme/app_theme.dart';
import '../../../../config/constants/app_constants.dart';

/// Map Page with OpenStreetMap
class MapPage
    extends
        StatefulWidget {
  const MapPage({
    super.key,
  });

  @override
  State<
    MapPage
  >
  createState() => _MapPageState();
}

class _MapPageState
    extends
        State<
          MapPage
        > {
  final MapController _mapController = MapController();
  LatLng _currentLocation = LatLng(
    AppConstants.defaultLatitude,
    AppConstants.defaultLongitude,
  );

  Map<
    String,
    dynamic
  >?
  _selectedStore;

  // Sample store data
  final List<
    Map<
      String,
      dynamic
    >
  >
  _stores = [
    {
      'id': 1,
      'name': 'Fresh Mart',
      'lat': 37.7749,
      'lng': -122.4194,
      'rating': 4.5,
      'distance': '1.2 km',
    },
    {
      'id': 2,
      'name': 'QuickShop',
      'lat': 37.7799,
      'lng': -122.4144,
      'rating': 4.2,
      'distance': '1.8 km',
    },
    {
      'id': 3,
      'name': 'Super Store',
      'lat': 37.7699,
      'lng': -122.4244,
      'rating': 4.7,
      'distance': '2.3 km',
    },
  ];

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentLocation,
              initialZoom: AppConstants.defaultZoom,
              onTap:
                  (
                    _,
                    __,
                  ) => setState(
                    () => _selectedStore = null,
                  ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.shoproute.app',
              ),
              // User location marker
              MarkerLayer(
                markers: [
                  Marker(
                    point: _currentLocation,
                    width: 40,
                    height: 40,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 3,
                        ),
                        boxShadow: AppTheme.shadowMd,
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              // Store markers
              MarkerLayer(
                markers: _stores.map(
                  (
                    store,
                  ) {
                    return Marker(
                      point: LatLng(
                        store['lat'],
                        store['lng'],
                      ),
                      width: 40,
                      height: 40,
                      child: GestureDetector(
                        onTap: () => setState(
                          () => _selectedStore = store,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color:
                                _selectedStore?['id'] ==
                                    store['id']
                                ? AppColors.accent
                                : AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                            boxShadow: AppTheme.shadowSm,
                          ),
                          child: const Icon(
                            Icons.store,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    );
                  },
                ).toList(),
              ),
            ],
          ),

          // Search bar
          Positioned(
            top:
                MediaQuery.of(
                  context,
                ).padding.top +
                16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(
                  12,
                ),
                boxShadow: AppTheme.shadowMd,
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search stores or addresses...',
                  border: InputBorder.none,
                  icon: const Icon(
                    Icons.search,
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      // TODO: Open filter drawer
                    },
                    icon: const Icon(
                      Icons.tune,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Recenter button
          Positioned(
            bottom:
                _selectedStore !=
                    null
                ? 200
                : 100,
            right: 16,
            child: FloatingActionButton.small(
              onPressed: () {
                _mapController.move(
                  _currentLocation,
                  AppConstants.defaultZoom,
                );
              },
              backgroundColor: AppColors.surfaceLight,
              child: const Icon(
                Icons.my_location,
                color: AppColors.primary,
              ),
            ),
          ),

          // Selected store bottom sheet
          if (_selectedStore !=
              null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(
                  20,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(
                      24,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(
                        0.1,
                      ),
                      blurRadius: 20,
                      offset: const Offset(
                        0,
                        -4,
                      ),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: AppColors.primarySurface,
                              borderRadius: BorderRadius.circular(
                                12,
                              ),
                            ),
                            child: const Icon(
                              Icons.store,
                              color: AppColors.primary,
                              size: 28,
                            ),
                          ),
                          const SizedBox(
                            width: 16,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedStore!['name'],
                                  style: AppTextStyles.titleLarge(),
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      size: 16,
                                      color: AppColors.warning,
                                    ),
                                    Text(
                                      ' ${_selectedStore!['rating']}',
                                      style: AppTextStyles.bodySmall(),
                                    ),
                                    Text(
                                      ' • ${_selectedStore!['distance']}',
                                      style: AppTextStyles.bodySmall(),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => setState(
                              () => _selectedStore = null,
                            ),
                            icon: const Icon(
                              Icons.close,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                // TODO: Navigate to store detail
                              },
                              icon: const Icon(
                                Icons.shopping_bag,
                              ),
                              label: const Text(
                                'View Products',
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 12,
                          ),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // TODO: Start navigation
                              },
                              icon: const Icon(
                                Icons.directions,
                              ),
                              label: const Text(
                                'Directions',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
