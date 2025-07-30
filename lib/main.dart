import 'dart:ffi' hide Size;
import 'dart:ui' show FlutterView;

import 'package:ffi/ffi.dart' as ffi;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  runWidget(
    MultiViewApp(
      viewBuilder: (BuildContext context) {
        var view = View.of(context);
        if (view.viewId == 0) {
          return const MyApp();
        } else {
          return const ChildPage();
        }
      },
    ),
  );
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
      home: const MyHomePage(title: 'Linux Multi-Window using FFI'),
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

  @Native<Void Function(Pointer)>(symbol: 'gtk_widget_show')
  external static void _gtkWidgetShow(Pointer widget);
  void show() {
    _gtkWidgetShow(pointer);
  }

  @Native<Void Function(Pointer)>(symbol: 'gtk_widget_destroy')
  external static void _gtkWindowDestroy(Pointer widget);
  void destroy() {
    _gtkWindowDestroy(pointer);
  }
}

class GtkWindow extends GtkWidget {
  @Native<Pointer Function(Int)>(symbol: 'gtk_window_new')
  external static Pointer _gtkWindowNew(int type);

  GtkWindow() : super(_gtkWindowNew(0));

  @Native<Void Function(Pointer, Pointer)>(symbol: 'gtk_container_add')
  external static void _gtkContainerAdd(Pointer container, Pointer child);
  void add(GtkWidget child) {
    _gtkContainerAdd(pointer, child.pointer);
  }

  @Native<Void Function(Pointer)>(symbol: 'gtk_window_present')
  external static void _gtkWindowPresent(Pointer window);
  void present() {
    _gtkWindowPresent(pointer);
  }

  @Native<Void Function(Pointer, Bool)>(symbol: 'gtk_window_set_decorated')
  external static void _gtkWindowSetDecorated(
    Pointer container,
    bool decorated,
  );
  void setDecorated(bool decorated) {
    _gtkWindowSetDecorated(pointer, decorated);
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

  @Native<Void Function(Pointer, Int, Int)>(
    symbol: 'gtk_window_set_default_size',
  )
  external static void _gtkWindowSetDefaultSize(
    Pointer window,
    int width,
    int height,
  );
  void setDefaultSize(int width, int height) {
    _gtkWindowSetDefaultSize(pointer, width, height);
  }

  //  @Native<Void Function(Pointer, Pointer<ffi.Utf8>)>(
  //    symbol: 'gtk_window_set_geometry_hints',
  //  )
  //  external static void _gtkWindowSetGeometryHints(
  //    Pointer window,
  //    Pointer geometryWidget,
  //    geometry,
  //    int geometryMask,
  //  );
  //  void setGeometryHints(Pointer window, geometry, int geometryMask) {
  //    _gtkGeometryHints(pointer, null, geometry, geometryMask);
  //  }

  @Native<Void Function(Pointer, Int, Int)>(symbol: 'gtk_window_resize')
  external static void _gtkWindowResize(Pointer window, int width, int height);
  void resize(int width, int height) {
    _gtkWindowResize(pointer, width, height);
  }

  @Native<Void Function(Pointer)>(symbol: 'gtk_window_maximize')
  external static void _gtkWindowMaximize(Pointer window);
  void maximize() {
    _gtkWindowMaximize(pointer);
  }

  @Native<Void Function(Pointer)>(symbol: 'gtk_window_unmaximize')
  external static void _gtkWindowUnmaximize(Pointer window);
  void unmaximize() {
    _gtkWindowUnmaximize(pointer);
  }

  @Native<Bool Function(Pointer)>(symbol: 'gtk_window_is_maximized')
  external static bool _gtkWindowIsMaximized(Pointer window);
  bool isMaximized() {
    return _gtkWindowIsMaximized(pointer);
  }

  @Native<Void Function(Pointer)>(symbol: 'gtk_window_iconify')
  external static void _gtkWindowIconify(Pointer window);
  void iconify() {
    _gtkWindowIconify(pointer);
  }

  @Native<Void Function(Pointer)>(symbol: 'gtk_window_deiconify')
  external static void _gtkWindowDeiconify(Pointer window);
  void deiconify() {
    _gtkWindowDeiconify(pointer);
  }
}

class FlView extends GtkWidget {
  @Native<Pointer Function(Pointer)>(symbol: 'fl_view_new_for_engine')
  external static Pointer _flViewNewForEngine(Pointer engine);

  FlView()
    : super(
        _flViewNewForEngine(
          Pointer.fromAddress(PlatformDispatcher.instance.engineId!),
        ),
      );

  @Native<Int64 Function(Pointer)>(symbol: 'fl_view_get_id')
  external static int _flViewGetId(Pointer view);
  int getId() {
    return _flViewGetId(pointer);
  }
}

class _MyHomePageState extends State<MyHomePage> {
  final titleController = TextEditingController(text: "Title");
  final widthController = TextEditingController(text: "300");
  final heightController = TextEditingController(text: "300");
  bool decorated = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Title",
                ),
                controller: titleController,
              ),
              SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Width",
                ),
                keyboardType: TextInputType.number,
                controller: widthController,
              ),
              SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Height",
                ),
                keyboardType: TextInputType.number,
                controller: heightController,
              ),
              SizedBox(height: 10),
              Row(
                children: <Widget>[
                  Text("Decorated"),
                  SizedBox(width: 10),
                  Switch(
                    value: decorated,
                    onChanged: (bool value) {
                      setState(() {
                        decorated = value;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 10),
              OutlinedButton(
                onPressed: () {
                  var window = GtkWindow();
                  var view = FlView();
                  view.show();
                  window.add(view);
                  window.setDecorated(decorated);
                  window.setTitle(titleController.text);
                  window.setDefaultSize(
                    int.parse(widthController.text),
                    int.parse(heightController.text),
                  );
                  window.present();
                },
                child: Text('CreateWindow'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChildPage extends StatelessWidget {
  const ChildPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        color: Colors.grey,
        child: Center(
          child: Text(
            'Hello World from View#${View.of(context).viewId}\n'
            'Logical ${MediaQuery.sizeOf(context)}\n'
            'DPR: ${MediaQuery.devicePixelRatioOf(context)}',
          ),
        ),
      ),
    );
  }
}

/// Calls [viewBuilder] for every view added to the app to obtain the widget to
/// render into that view. The current view can be looked up with [View.of].
class MultiViewApp extends StatefulWidget {
  const MultiViewApp({super.key, required this.viewBuilder});

  final WidgetBuilder viewBuilder;

  @override
  State<MultiViewApp> createState() => _MultiViewAppState();
}

class _MultiViewAppState extends State<MultiViewApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _updateViews();
  }

  @override
  void didUpdateWidget(MultiViewApp oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Need to re-evaluate the viewBuilder callback for all views.
    _views.clear();
    _updateViews();
  }

  @override
  void didChangeMetrics() {
    _updateViews();
  }

  Map<Object, Widget> _views = <Object, Widget>{};

  void _updateViews() {
    final Map<Object, Widget> newViews = <Object, Widget>{};
    for (final FlutterView view
        in WidgetsBinding.instance.platformDispatcher.views) {
      final Widget viewWidget = _views[view.viewId] ?? _createViewWidget(view);
      newViews[view.viewId] = viewWidget;
    }
    setState(() {
      _views = newViews;
    });
  }

  Widget _createViewWidget(FlutterView view) {
    return View(
      view: view,
      child: Builder(builder: widget.viewBuilder),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ViewCollection(views: _views.values.toList(growable: false));
  }
}
