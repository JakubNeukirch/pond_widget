import 'package:flutter/material.dart';
import 'package:pond_effect_2/pond_effect.dart';

class PondButton extends StatelessWidget {
  final Widget child;
  final Function? onClick;
  const PondButton({required this.child, this.onClick, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onClick?.call();
      },
      child: PondWidget(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(8)
          ),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: child,
          ),
        ),
      ),
    );
  }
}


class PondWidget extends StatefulWidget {
  final Widget child;
  const PondWidget({required this.child,Key? key}) : super(key: key);

  @override
  _PondWidgetState createState() => _PondWidgetState();
}

class _PondWidgetState extends State<PondWidget> {
  GlobalKey<PondEffectState> _pond = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        _pond.currentState?.click(details.globalPosition.dx.toInt(), details.globalPosition.dy.toInt());
      },
      child: LayoutBuilder(
        builder: (context, constraints) => Container(
          decoration: BoxDecoration(),
          clipBehavior: Clip.hardEdge,
          child: PondEffect(
            key: _pond,
            size: constraints.biggest,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
