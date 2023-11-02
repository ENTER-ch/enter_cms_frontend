import 'package:flutter/material.dart';

class DevicesPage extends StatelessWidget {
  const DevicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Devices',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ],
    );
  }
}
