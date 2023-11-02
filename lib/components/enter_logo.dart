import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EnterLogo extends StatelessWidget {
  const EnterLogo({
    super.key,
    this.width,
    this.height,
    this.color,
  });

  final double? width;
  final double? height;

  final Color? color;

  static const String assetName = 'assets/svg/enter-logo.svg';

  @override
  Widget build(BuildContext context) {
    final Widget svgPicture = SvgPicture.asset(assetName,
        width: width,
        height: height,
        color: color,
        semanticsLabel: 'ENTER Logo');

    return svgPicture;
  }
}
