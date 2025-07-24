import 'dart:ffi' hide Size;

import 'package:ffi/ffi.dart' as ffi;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

@Native<Bool Function(Int64)>(symbol: 'InternalFlutterLinux_HasTopLevelWindows')
external bool _hasTopLevelWindows(int engineId);

@Native<Int64 Function(Int64)>(
  symbol: 'InternalFlutterLinux_CreateRegularWindow',
)
external int _createRegularWindow(int engineId);

@Native<Pointer Function(Int64, Int64)>(
  symbol: 'InternalFlutterLinux_GetGtkWindow',
)
external Pointer _getGtkWindow(int engineId, int viewId);

@Native<Void Function(Pointer)>(symbol: 'gtk_window_present')
external void _gtkWindowPresent(Pointer window);

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
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            OutlinedButton(
              onPressed: () {
                var engineId = PlatformDispatcher.instance.engineId!;
                var viewId = _createRegularWindow(engineId);
                var window = _getGtkWindow(engineId, viewId);
                _gtkWindowPresent(window);
              },
              child: Text('CreateWindow'),
            ),
          ],
        ),
      ),
    );
  }
}
