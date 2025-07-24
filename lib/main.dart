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

class GtkWidget {
  final Pointer pointer;

  const GtkWidget(this.pointer);

  @Native<Void Function(Pointer)>(symbol: 'gtk_widget_destroy')
  external static void _gtkWindowDestroy(Pointer widget);
  void destroy() {
    _gtkWindowDestroy(pointer);
  }
}

class GtkWindow extends GtkWidget {
  const GtkWindow(super.pointer);

  @Native<Void Function(Pointer)>(symbol: 'gtk_window_present')
  external static void _gtkWindowPresent(Pointer window);
  void present() {
    _gtkWindowPresent(pointer);
  }

  @Native<Void Function(Pointer, Pointer<ffi.Utf8>)>(
    symbol: 'gtk_window_set_title',
  )
  external static void _gtkWindowSetTitle(
    Pointer window,
    Pointer<ffi.Utf8> title,
  );
  void setTitle(String title) {
    _gtkWindowSetTitle(pointer, title.toNativeUtf8());
  }
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
                var window = GtkWindow(_getGtkWindow(engineId, viewId));
                //window.present();
              },
              child: Text('CreateWindow'),
            ),
          ],
        ),
      ),
    );
  }
}
