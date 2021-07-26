import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:image/image.dart' as img;

class PondEffect extends StatefulWidget {
  final Widget child;
  final Size size;

  PondEffect({required this.child, required this.size, Key? key})
      : super(key: key);

  @override
  PondEffectState createState() => PondEffectState();
}

class PondEffectState extends State<PondEffect> with TickerProviderStateMixin {
  late AnimationController _controller;
  double dampening = 0.96;

  late img.Image _editableImage;
  late List<List<double>> previous;
  late List<List<double>> current;
  late Size canvasSize;
  static const maxWidth = 100;

  @override
  void initState() {
    super.initState();
    _invalidateSize();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    )
      ..addListener(() {
        setState(() {
          calculate();
        });
      })
      ..repeat();
  }

  void _invalidateSize() {
    final aspectRatio = widget.size.width / widget.size.height;
    this.canvasSize = maxWidth < widget.size.width
        ? Size(maxWidth.toDouble(), maxWidth / aspectRatio)
        : widget.size;
    _editableImage =
        img.Image(canvasSize.width.round(), canvasSize.height.round());
    previous = List.generate(canvasSize.width.round(),
            (index) => List.generate(canvasSize.height.round(), (index) => 0.0));
    current = List.generate(canvasSize.width.round(),
            (index) => List.generate(canvasSize.height.round(), (index) => 0.0));
  }

  void click(int x, int y) {
    final newX = (x * (canvasSize.width / widget.size.width)).round();
    final newY = (y * (canvasSize.height / widget.size.height)).round();
    previous[newX][newY] = 1000;
  }

  void calculate() {
    final far = 1;
    for (int i = far; i < canvasSize.width.round() - far; i++) {
      for (int j = far; j < canvasSize.height.round() - far; j++) {
        current[i][j] = ((previous[i - far][j] +
                    previous[i + far][j] +
                    previous[i][j - far] +
                    previous[i][j + far]) /
                2 -
            current[i][j]);
        current[i][j] = current[i][j] * dampening;
        final value = (current[i][j]).toInt();
        _editableImage.setPixelRgba(
            i, j, value * 3, value * 3, value * 3, value);
      }
    }
    final temp = previous;
    previous = current;
    current = temp;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ShaderWidget(
      child: widget.child,
      canvasSize: canvasSize,
      fullSize: widget.size,
      waveOverlay: _editableImage,
    );
  }
}

class ShaderWidget extends SingleChildRenderObjectWidget {
  final img.Image waveOverlay;
  final Size canvasSize;
  final Size? fullSize;

  ShaderWidget(
      {Widget? child,
      this.fullSize,
      required this.canvasSize,
      required this.waveOverlay})
      : super(child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderShader(canvasSize: canvasSize, fullSize: fullSize);
  }

  @override
  void updateRenderObject(BuildContext context, RenderObject renderObject) {
    super.updateRenderObject(context, renderObject);
    (renderObject as RenderShader).waveChanged(waveOverlay);
  }
}

class RenderShader extends RenderProxyBox {
  late img.Image _editableImage;
  ui.Image? drawImage;
  Size canvasSize;
  Rect? srcRect;
  final Size? fullSize;

  RenderShader({required this.canvasSize, this.fullSize, RenderBox? renderBox})
      : super(renderBox) {
    _editableImage = img.Image(
        this.canvasSize.width.round(), this.canvasSize.height.round());
    srcRect = Offset.zero & canvasSize;
  }

  void waveChanged(img.Image overlay) {
    _editableImage = overlay;
    drawCurrent();
  }

  drawCurrent() {
    ui.decodeImageFromPixels(
        _editableImage.getBytes(),
        canvasSize.width.round(),
        canvasSize.height.round(),
        ui.PixelFormat.rgba8888, (result) {
      drawImage = result;
      markNeedsPaint();
      markNeedsLayout();
    });
  }

  final painter = Paint()
    ..imageFilter = ImageFilter.blur(sigmaY: 6.0, sigmaX: 6.0)
    ..isAntiAlias = true;

  @override
  void paint(PaintingContext context, Offset offset) {
    context.paintChild(child!, offset);
    if (drawImage != null) {
      context.canvas.drawImageRect(
          drawImage!, srcRect!, Offset.zero & fullSize!, painter);
    }
  }
}

Color colorFromABGR(int value) {
  final alpha = value & 0xff000000;
  final blue = value & 0x00ff0000;
  final green = value & 0x0000ff00;
  final red = value & 0x000000ff;
  return Color.fromARGB(alpha, red, green, blue);
}
