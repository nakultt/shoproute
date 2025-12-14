import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
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
  bool _isLoadingLocation = false;
  bool _locationError = false;

  Map<
    String,
    dynamic
  >?
  _selectedStore;

  // Sample store data with products
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
      'address': '123 Market St, San Francisco, CA',
      'products': [
        {
          'name': 'Organic Milk',
          'price': 4.99,
        },
        {
          'name': 'Fresh Bread',
          'price': 3.49,
        },
        {
          'name': 'Farm Eggs',
          'price': 5.99,
        },
      ],
    },
    {
      'id': 2,
      'name': 'QuickShop',
      'lat': 37.7799,
      'lng': -122.4144,
      'rating': 4.2,
      'distance': '1.8 km',
      'address': '456 Valencia St, San Francisco, CA',
      'products': [
        {
          'name': 'Canned Soup',
          'price': 2.99,
        },
        {
          'name': 'Pasta',
          'price': 1.99,
        },
        {
          'name': 'Olive Oil',
          'price': 8.99,
        },
      ],
    },
    {
      'id': 3,
      'name': 'Super Store',
      'lat': 37.7699,
      'lng': -122.4244,
      'rating': 4.7,
      'distance': '2.3 km',
      'address': '789 Mission St, San Francisco, CA',
      'products': [
        {
          'name': 'Fresh Salmon',
          'price': 12.99,
        },
        {
          'name': 'Avocados',
          'price': 1.49,
        },
        {
          'name': 'Quinoa',
          'price': 6.99,
        },
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _detectLocation();
  }

  Future<
    void
  >
  _detectLocation() async {
    setState(
      () {
        _isLoadingLocation = true;
        _locationError = false;
      },
    );

    try {
      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission ==
          LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission ==
            LocationPermission.denied) {
          throw Exception(
            'Location permission denied',
          );
        }
      }

      if (permission ==
          LocationPermission.deniedForever) {
        throw Exception(
          'Location permission permanently denied',
        );
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(
        () {
          _currentLocation = LatLng(
            position.latitude,
            position.longitude,
          );
          _isLoadingLocation = false;
        },
      );

      _mapController.move(
        _currentLocation,
        AppConstants.defaultZoom,
      );
    } catch (
      e
    ) {
      setState(
        () {
          _isLoadingLocation = false;
          _locationError = true;
        },
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(
            content: Text(
              'Could not get location: ${e.toString()}',
            ),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: _detectLocation,
            ),
          ),
        );
      }
    }
  }

  void _openDirections(
    Map<
      String,
      dynamic
    >
    store,
  ) async {
    final lat = store['lat'];
    final lng = store['lng'];
    final storeName = store['name'];

    // Try Google Maps first, then Apple Maps
    final googleMapsUrl = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&destination_place_id=$storeName';
    final appleMapsUrl = 'https://maps.apple.com/?daddr=$lat,$lng&dirflg=d';

    if (await canLaunchUrl(
      Uri.parse(
        googleMapsUrl,
      ),
    )) {
      await launchUrl(
        Uri.parse(
          googleMapsUrl,
        ),
        mode: LaunchMode.externalApplication,
      );
    } else if (await canLaunchUrl(
      Uri.parse(
        appleMapsUrl,
      ),
    )) {
      await launchUrl(
        Uri.parse(
          appleMapsUrl,
        ),
        mode: LaunchMode.externalApplication,
      );
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not open maps application',
            ),
          ),
        );
      }
    }
  }

  void _showStoreProducts(
    Map<
      String,
      dynamic
    >
    store,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (
            ctx,
          ) => DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.3,
            maxChildSize: 0.9,
            builder:
                (
                  _,
                  scrollController,
                ) => Container(
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(
                        24,
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.borderLight,
                          borderRadius: BorderRadius.circular(
                            2,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  store['name'],
                                  style: AppTextStyles.headlineSmall(),
                                ),
                                Text(
                                  store['address'] ??
                                      '',
                                  style: AppTextStyles.bodySmall(),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  size: 18,
                                  color: AppColors.warning,
                                ),
                                Text(
                                  ' ${store['rating']}',
                                  style: AppTextStyles.labelMedium(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Divider(
                        height: 24,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Available Products',
                              style: AppTextStyles.titleMedium(),
                            ),
                            Text(
                              '${(store['products'] as List).length} items',
                              style: AppTextStyles.bodySmall(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                          ),
                          itemCount:
                              (store['products']
                                      as List)
                                  .length,
                          itemBuilder:
                              (
                                _,
                                index,
                              ) {
                                final product = store['products'][index];
                                return Container(
                                  margin: const EdgeInsets.only(
                                    bottom: 12,
                                  ),
                                  padding: const EdgeInsets.all(
                                    16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.backgroundLight,
                                    borderRadius: BorderRadius.circular(
                                      12,
                                    ),
                                    border: Border.all(
                                      color: AppColors.borderLight,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: AppColors.primarySurface,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.inventory_2,
                                          color: AppColors.primary,
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
                                              product['name'],
                                              style: AppTextStyles.titleSmall(),
                                            ),
                                            Text(
                                              '\$${product['price']}',
                                              style: AppTextStyles.price(),
                                            ),
                                          ],
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(
                                            ctx,
                                          );
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                '${product['name']} added to cart',
                                              ),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                        ),
                                        child: const Text(
                                          'Add',
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

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
            child: Column(
              children: [
                if (_isLoadingLocation)
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      shape: BoxShape.circle,
                      boxShadow: AppTheme.shadowMd,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(
                        10,
                      ),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                  )
                else
                  FloatingActionButton.small(
                    onPressed: _detectLocation,
                    heroTag: 'location',
                    backgroundColor: _locationError
                        ? AppColors.errorLight
                        : AppColors.surfaceLight,
                    child: Icon(
                      _locationError
                          ? Icons.location_disabled
                          : Icons.my_location,
                      color: _locationError
                          ? AppColors.error
                          : AppColors.primary,
                    ),
                  ),
              ],
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
                      if (_selectedStore!['address'] !=
                          null) ...[
                        const SizedBox(
                          height: 8,
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 16,
                              color: AppColors.textSecondaryLight,
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                            Expanded(
                              child: Text(
                                _selectedStore!['address'],
                                style: AppTextStyles.bodySmall(),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(
                        height: 16,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _showStoreProducts(
                                _selectedStore!,
                              ),
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
                              onPressed: () => _openDirections(
                                _selectedStore!,
                              ),
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
