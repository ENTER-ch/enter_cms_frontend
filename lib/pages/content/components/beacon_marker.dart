import 'package:enter_cms_flutter/models/beacon.dart';
import 'package:flutter/material.dart';

class BeaconMarker extends StatelessWidget {
  const BeaconMarker({
    super.key,
    required this.beacon,
  });

  final MBeacon beacon;

  @override
  Widget build(BuildContext context) {
    final radius = beacon.radius ?? 200.0;
    return Transform.translate(
      offset: Offset(-radius / 2, -radius / 2),
      child: Container(
        width: radius,
        height: radius,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Theme.of(context).colorScheme.error.withOpacity(.2),
            width: 8,
          ),
          color: Theme.of(context).colorScheme.error.withOpacity(0.1),
        ),
      ),
    );
  }
}
