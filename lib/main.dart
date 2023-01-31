import 'package:enter_cms_flutter/bootstrap.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Logger.root.level = Level.FINEST;

  await startApplication();
}