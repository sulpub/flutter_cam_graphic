import 'dart:async';
import 'dart:convert' show utf8;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:oscilloscope/oscilloscope.dart';
//import 'package:mqtt_client/mqtt_client.dart';

FlutterBlue flutterBlue = FlutterBlue.instance;

void main() {
  //hide android status bar
  //SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
  //SystemChrome..setEnabledSystemUIOverlays([]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NGL Sensors',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'IoT Sensors'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();

}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  // Whether the "A propos" box should be visible
  bool _visible_a_propos = false;

  List<double> traceSine = [];
  List<double> traceCosine = [];
  double radians = 0.0;
  Timer? _timer;

  /// method to generate a Test  Wave Pattern Sets
  /// this gives us a value between +1  & -1 for sine & cosine
  _generateTrace(Timer t) {
    // generate our  values
    var sv = 0.3*Random(1)+sin((radians * pi));
    var cv = 0.3*Random(10)+cos((radians * pi));

    // Add to the growing dataset
    setState(() {
      traceSine.add(sv);
      traceCosine.add(cv);
    });

    // adjust to recyle the radian value ( as 0 = 2Pi RADS)
    radians += 0.05;
    if (radians >= 2.0) {
      radians = 0.0;
    }
  }

  @override
  initState() {
    super.initState();
    // create our timer to generate test values
    _timer = Timer.periodic(Duration(milliseconds: 60), _generateTrace);
  }

  @override
  void dispose() {
    _timer!.cancel();
    super.dispose();
  }

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  void _decrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter--;
    });
  }


  void _scanBluetoothDevices() {
    // Start scanning
    flutterBlue.startScan(timeout: Duration(seconds: 4));

    // Listen to scan results
    var subscription = flutterBlue.scanResults.listen((results) {
      // do something with scan results
      for (ScanResult r in results) {
        //print('${r.device.name} found! rssi: ${r.rssi}');
        if('${r.device.name}' == "Sensors NGL")
        {
          print('NGL device found');
          flutterBlue.stopScan();
          break;
        }
      }
    });

    // Stop scanning
    flutterBlue.stopScan();
  }



  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    // Create A Scope Display for Sine
    Oscilloscope scopeOne = Oscilloscope(
      showYAxis: true,
      yAxisColor: Colors.orange,
      margin: EdgeInsets.all(20.0),
      strokeWidth: 1.0,
      backgroundColor: Colors.black,
      traceColor: Colors.green,
      yAxisMax: 1.0,
      yAxisMin: -1.0,
      dataSet: traceSine,
    );

    // Create A Scope Display for Cosine
    Oscilloscope scopeTwo = Oscilloscope(
      showYAxis: true,
      margin: EdgeInsets.all(20.0),
      strokeWidth: 3.0,
      backgroundColor: Colors.black,
      traceColor: Colors.yellow,
      yAxisMax: 1.0,
      yAxisMin: -1.0,
      dataSet: traceCosine,
    );


    return Scaffold(

      //Application bar
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),

      //left menu
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: const <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: const Color(0xFF778899),
              ),
              child: Text(
                'Options',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.aspect_ratio),
              title: Text('Graphique'),
            ),
            ListTile(
              leading: Icon(Icons.account_circle),
              title: Text('Profil'),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Parametres'),
            ),
          ],
        ),
      ),

      //main screen
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.

        /*
        child: AnimatedOpacity(
          // If the widget is visible, animate to 0.0 (invisible).
          // If the widget is hidden, animate to 1.0 (fully visible).
          opacity: _visible_a_propos ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 100),
            // Logo.
             child: Container(
              width: 100.0,
              height: 100.0,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('images/ic_launcher.png'),
                  fit: BoxFit.fill,
                ),
                shape: BoxShape.rectangle,
              ),
            ),

        ),
        */

        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Scope for visualization',
            ),
            Expanded(flex: 1, child: scopeOne),
            Expanded(flex: 1, child: scopeTwo),
            /*
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
            Image(image: AssetImage('images/ic_launcher.png')),
            */
          ],
        ),

      ),

      /*
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
      floatingActionButton: FloatingActionButton(
        onPressed: _decrementCounter,
        tooltip: 'Decrement',
        child: const Icon(Icons.exposure_minus_1),
      ),
      */

        floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              /*
              FloatingActionButton.extended(
                label: const Text(''),
                icon: const Icon(Icons.camera),
                backgroundColor: Colors.blue,
                onPressed: _incrementCounter,
                heroTag: null,
              ),
              */
              FloatingActionButton(
                child: Icon(
                  Icons.camera,
                ),
                onPressed: _incrementCounter,
                heroTag: null,
                backgroundColor: Colors.blue,
              ),
              SizedBox(
                height: 10,
                //width: 10,
              ),
              FloatingActionButton(
                child: Icon(
                    Icons.construction,
                ),
                onPressed: _scanBluetoothDevices,
                heroTag: null,
                backgroundColor: Colors.grey,
              ),
              SizedBox(
                height: 10,
                //width: 10,
              ),
              FloatingActionButton(
                child: Icon(
                  Icons.flip,
                ),
                onPressed: () {
                  // Call setState. This tells Flutter to rebuild the
                  // UI with the changes.
                  setState(() {
                    _visible_a_propos = !_visible_a_propos;
                  });
                },
                heroTag: null,
                backgroundColor: Colors.grey,
              ),
            ]
        ),

    );
  }
}


