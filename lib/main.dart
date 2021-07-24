import 'package:flutter/material.dart';
import 'package:pond_effect_2/pond_widget.dart';

import 'pond_effect.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PondPage(),
    );
  }
}

class PondPage extends StatefulWidget {
  @override
  _PondPageState createState() => _PondPageState();
}

class _PondPageState extends State<PondPage> {
  GlobalKey<PondEffectState> _pond = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTapDown: (details) {
          _pond.currentState?.click(details.localPosition.dx.toInt(), details.localPosition.dy.toInt());
        },
        child: Container(
          width: double.maxFinite,
          height: double.maxFinite,
          color: Colors.black,
          /*child: Center(
            child: PondButton(
              child: Text("Click!", style: TextStyle(color: Colors.white),),
              onClick: (){},
            )
          ),*/
          child: Center(
            child: PondWidget(
              child: Image.network(
                "https://i.pinimg.com/originals/aa/89/a7/aa89a70aae2be0782816eb0404efd25b.jpg",
                fit: BoxFit.contain,
              ),
            )
          ),
        ),
      ),
    );
  }
}
