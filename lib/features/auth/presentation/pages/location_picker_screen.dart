import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/utils/values/app_colors.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/primary_button.dart';
import '../widgets/auth_app_bar.dart';

/// Full-screen map with a fixed centre pin. The merchant pans the map under
/// the pin; "confirm" pops the route with the pin's [LatLng].
class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key, this.initialLocation});

  /// Zone 7 (Mansoura), the zone new stores register in.
  static const LatLng defaultLocation = LatLng(31.0300, 31.3850);

  /// Previously picked location, if the merchant is changing it.
  final LatLng? initialLocation;

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  static const double _initialZoom = 15;

  // Notifier rather than setState: onCameraMove fires every frame while
  // dragging, and only the coordinates label needs to rebuild.
  late final ValueNotifier<LatLng> _target = ValueNotifier<LatLng>(
    widget.initialLocation ?? LocationPickerScreen.defaultLocation,
  );

  @override
  void dispose() {
    _target.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: const AuthAppBar(),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _target.value,
                    zoom: _initialZoom,
                  ),
                  onCameraMove: (CameraPosition position) =>
                      _target.value = position.target,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                ),
                // Lifted by half its height so the pin's tip marks the centre.
                IgnorePointer(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 44),
                    child: Icon(
                      Icons.location_on,
                      size: 44,
                      color: colors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    Strings.moveMapToPlacePin,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13.5,
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ValueListenableBuilder<LatLng>(
                    valueListenable: _target,
                    builder: (_, LatLng target, __) => Text(
                      formatLatLng(target),
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.ltr,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    label: Strings.confirmLocation,
                    onPressed: () => context.pop<LatLng>(_target.value),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// `31.030000, 31.385000` — 6 decimals is ~0.1 m, plenty for a storefront.
String formatLatLng(LatLng latLng) =>
    '${latLng.latitude.toStringAsFixed(6)}, '
    '${latLng.longitude.toStringAsFixed(6)}';
