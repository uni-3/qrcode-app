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
@immutable
class ConfirmViewArguments {
  const ConfirmViewArguments({
    required this.type,
    required this.data
  });
  final String type;
  final String data;
}

class QRcodeScannerView extends StatefulWidget {
  @override
  _QRcodeScannerViewState createState() => _QRcodeScannerViewState();
}

class _QRcodeScannerViewState extends State<QRcodeScannerView> {
  QRViewController? _qrController;
  final GlobalKey _qrKey = GlobalKey(debugLabel: 'QR');
  bool _isQRScanned = false;

  @override
  void reassemble(){
    super.reassemble();
    if (Platform.isAndroid) {
      _qrController?.parseCamera();
    }
    _qrController?.resumeCamera();
  }

  @override
  void dispose() {
    _qrController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("scan QR code")),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 4,
            child: _buildQRView(context)
          ),
          Expanded(
            flex: 1,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  const Text("scan code"),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: ElevatedButton(
                          onPressed: () async {
                            await _qrController?.toggleFlash();
                            setState(() {});
                          },
                          child: FutureBuilder(
                            future: _qrController?.getFlashStatus(),
                            builder: (context, snapshot) => Text("Flash: ${snapshot.data}"),
                          )
                        )
                      ),
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: ElevatedButton(
                          onPressed: () async {
                            await _qrController?.toggleFlash();
                            setState(() {});
                          },
                          child: FutureBuilder(
                            future: _qrController?.getCameraInfo(),
                            builder: (context, snapshot) => snapshot.data != null ? Text(
                              "camera facing ${describeEnum(snapshot.data!)}"
                              ) : const Text("loading"),
                            )
                          )
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: ElevatedButton(
                          onPressed: () async {
                            await _qrController?.pauseCamera();
                          },
                          child: const Text(
                            "pause",
                            style: TextStyle(fontSize: 20)
                          )
                        )
                      ),
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: ElevatedButton(
                          onPressed: () async {
                            await _qrController?.resumeCamera();
                          },
                          child: const Text(
                            "resume",
                            style: TextStyle(fontSize: 20)
                          )
                        )
                      ),
                    ],
                  )
                ],
              )
            )

          )
        ],
      ),
    );
  }

  Widget _buildQRView(BuildContext context) {

  }


}