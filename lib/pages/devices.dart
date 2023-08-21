import 'package:flutter/material.dart';

class DevicesPage extends StatelessWidget {
  const DevicesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Devices', style: Theme.of(context).textTheme.titleLarge,),
    );
  }
}
