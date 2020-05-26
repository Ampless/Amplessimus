import 'package:amplissimus/animations.dart';
import 'package:amplissimus/prefs.dart';
import 'package:amplissimus/values.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AmpStrings.appTitle,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: AmpStrings.appTitle, textStyle: TextStyle(color: AmpColors.colorForeground),),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title, @required this.textStyle}) : super(key: key);
  final String title;
  TextStyle textStyle;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;


  void _incrementCounter() {
    setState(() {
      _counter = Prefs.counter;
      _counter++;
      _counter++;
      Prefs.saveCounter(_counter);
    });
  }

  @override
  Widget build(BuildContext context) {
    Prefs.loadPrefs();
    _counter = Prefs.counter;
    return Scaffold(
      backgroundColor: AmpColors.colorBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('You have pushed the button this many times:', style: widget.textStyle),
            Text('$_counter', style: TextStyle(color: AmpColors.colorForeground, fontSize: 30)),
            RaisedButton(
              onPressed: () {
                Prefs.saveCurrentDesignMode(!AmpColors.isDarkMode);
                Animations.changeScreenEaseOutBack(new MyApp(), context);
              }
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AmpColors.colorBackground,
        splashColor: AmpColors.colorForeground,
        onPressed: _incrementCounter,
        icon: Icon(Icons.add),
        label: Text('Zählen'),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
