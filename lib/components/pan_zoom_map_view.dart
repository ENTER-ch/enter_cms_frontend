import 'dart:math';
import 'package:enter_cms_flutter/components/interactive_viewer.dart';
import 'package:enter_cms_flutter/models/floorplan.dart';
import 'package:vector_math/vector_math_64.dart' as vector_math;
import 'package:flutter/material.dart';

class PanZoomMapView extends StatefulWidget {
  const PanZoomMapView({
    Key? key,
    this.floorplan,
    this.overlayBuilder,
    this.onTap,
  }) : super(key: key);

  final MFloorplan? floorplan;
  final Widget Function(BuildContext context, vector_math.Quad viewport, double scaleFactor)? overlayBuilder;
  final void Function(Offset position)? onTap;

  @override
  State<PanZoomMapView> createState() => _PanZoomMapViewState();
}

class _PanZoomMapViewState extends State<PanZoomMapView>
    with TickerProviderStateMixin {

  final _transformationController = TransformationController();
  Animation<Matrix4>? _animationReset;
  late final AnimationController _controllerReset;

  Size _mapSize = const Size(0,0);
  NetworkImage? _mapImage;
  bool _loading = true;

  @override
  void initState() {
    super.initState();

    _controllerReset = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    WidgetsBinding.instance.scheduleFrameCallback((_) async {
      _loadImage();
    });
  }

  @override
  void didUpdateWidget(covariant PanZoomMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.floorplan != widget.floorplan) {
      _loadImage();
      _animateResetInitialize();
    }
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _controllerReset.dispose();
    super.dispose();
  }

  void _loadImage() async {
    if (widget.floorplan != null) {
      setState(() {
        _loading = true;
      });

      _setSize();
      _mapImage = NetworkImage(widget.floorplan!.image);
      await precacheImage(_mapImage!, context);

      setState(() {
        _loading = false;
      });
    }
  }

  void _setSize() {
    if (widget.floorplan != null) {
      setState(() {
        _mapSize = Size(widget.floorplan!.width.toDouble(),
            widget.floorplan!.height.toDouble());
      });
      _transformationController.value = _getInitialScaleMatrix();
    }
  }

  double _getInitialScaleFactor() {
    final size = MediaQuery.of(context).size;
    return min(size.width / _mapSize.width, size.height / _mapSize.height);
  }

  double _getCurrentScaleFactor() {
    final matrix = _transformationController.value;
    return matrix.getMaxScaleOnAxis();
  }

  Matrix4 _getInitialScaleMatrix() {
    final scaleFactor = _getInitialScaleFactor();
    return Matrix4.identity()..scale(scaleFactor, scaleFactor);
  }

  void _onAnimateReset() {
    _transformationController.value = _animationReset!.value;
    if (!_controllerReset.isAnimating) {
      _animationReset!.removeListener(_onAnimateReset);
      _animationReset = null;
      _controllerReset.reset();
    }
  }

  void _animateResetInitialize() {
    _controllerReset.reset();
    _animationReset = Matrix4Tween(
      begin: _transformationController.value,
      end: _getInitialScaleMatrix(),
    ).animate(_controllerReset);
    _animationReset!.addListener(_onAnimateReset);
    _controllerReset.forward();
  }

  // Stop a running reset to home transform animation.
  void _animateResetStop() {
    _controllerReset.stop();
    _animationReset?.removeListener(_onAnimateReset);
    _animationReset = null;
    _controllerReset.reset();
  }

  void _onInteractionStart(ScaleStartDetails details) {
    // If the user tries to cause a transformation while the reset animation is
    // running, cancel the reset animation.
    if (_controllerReset.status == AnimationStatus.forward) {
      _animateResetStop();
    }
  }

  void _onTap(TapDownDetails details) {
    widget.onTap?.call(details.localPosition);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.floorplan == null) {
      return const Center(
        child: Text('Select or create a floorplan'),
      );
    }

    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final size = MediaQuery.of(context).size;
    return Stack(
      children: [
        CustomInteractiveViewer.builder(
          trackpadScrollCausesScale: true,
          transformationController: _transformationController,
          onInteractionStart: _onInteractionStart,
          maxScale: 2.0,
          minScale: _getInitialScaleFactor(),
          boundaryMargin: EdgeInsets.symmetric(horizontal: size.width, vertical: size.height),
          builder: (context, viewport) {
            final overlay = widget.overlayBuilder?.call(context, viewport, _getCurrentScaleFactor());
            return GestureDetector(
              onTapDown: _onTap,
              child: SizedBox(
                width: _mapSize.width,
                height: _mapSize.height,
                child: Stack(
                  children: [
                    _buildMapImage(),
                    if (overlay != null) overlay,
                  ],
                ),
              ),
            );
          },
        ),
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            onPressed: _animateResetInitialize,
            child: const Icon(Icons.home),
          ),
        ),
      ],
    );
  }

  Widget _buildMapImage() {
    if (_mapImage != null) {
      return Image(
        image: _mapImage!,
      );
    }
    return const SizedBox();
  }
}
