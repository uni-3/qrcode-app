import 'dart:html';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'qr code reader',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}


class ReaderPageView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primaryColor: Colors.white),
      routes: <String, WidgetBuilder>{
        routeReaderPage: (BuildContext context) => ReaderPageView(),
        routeQRcodeScanner: (BuildContext context) => QRCodeScannerView(),
        routeConfirm: (BuildContext context) => ConfirmView(),
      },
      home: _ReaderPage(),
    );
  }
}

class _ReaderPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text("qr code scanner"),
      ),
      body: _buildPage(context)
    );
  }
}

Widget _buildPage(BuildContext context) {
  return Center(
    child: ElevatedButton(
      onPressed: () async {
        if (await Permission.camera.request().isGranted) {
          Navigator.pushNamed(context, routeQRcodeScanner)
        } else {
          await showRequestPermissionDialog(context);
        }
      },
      child: const Text("launch qr code scanner"),
    ),
  );
}

Future<void> showRequestPermissionDialog(BuildContext context) async {
  await showDialog<void>(
    context: context,
    builder: buildDialog(context),
  );
}

buildDialog(BuildContext context) {
  return AlertDialog(
    title: const Text("カメラの使用を許可してください"),
    content: const Text("QRコードを読み取るためにカメラを使用します"),
    actions: <Widget>[
      ElevatedButton(
        onPressed: () => Navigator.pop(context),
        child: const Text("cancel"),
      ),
      ElevatedButton(
        onPressed: () async => (openAppSettings()),
        child: const Text("setting"),
      ),
    ],
  );
}


// qr code scanner view