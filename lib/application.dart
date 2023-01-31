import 'package:enter_cms_flutter/router.dart';
import 'package:enter_cms_flutter/theme.dart';
import 'package:flutter/material.dart';

class EnterCmsApplication extends StatefulWidget {
  const EnterCmsApplication({Key? key}) : super(key: key);

  @override
  State<EnterCmsApplication> createState() => _EnterCmsApplicationState();
}

class _EnterCmsApplicationState extends State<EnterCmsApplication> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: router,
    );
  }
}
