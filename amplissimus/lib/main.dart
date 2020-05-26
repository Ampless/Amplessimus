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
      home: MyHomePage(title: AmpStrings.appTitle),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

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
      appBar: AppBar(
        title: Text(widget.title, style: TextStyle(color: AmpColors.colorForeground)),
        backgroundColor: Colors.transparent,
        bottomOpacity: 0.0,
        elevation: 0.0,
        iconTheme: IconThemeData(
          color: Colors.black
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('You have pushed the button this many times:', style: TextStyle(color: AmpColors.colorForeground)),
            Text('$_counter', style: TextStyle(color: AmpColors.colorForeground, fontSize: 30)),
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
