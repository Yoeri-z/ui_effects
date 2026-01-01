import 'package:flutter/material.dart';
import 'package:ui_effects/ui_effects.dart';

UICenter get ui => UICenter.instance;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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

class ConfirmationDialog extends StatelessWidget {
  const ConfirmationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(4),
      ),
      child: ConfirmationContent(),
    );
  }
}

class ConfirmationContent extends StatelessWidget {
  const ConfirmationContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Are you sure that you want to increment the counter?'),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Yes'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() async {
    final allowed = await ui.showDialog<bool>(ConfirmationDialog());

    if (allowed != null && allowed) {
      setState(() {
        _counter++;
      });
      ui.showSnackBar(
        SnackBar(content: Text('Incremented counter')),
        duration: Duration(seconds: 3),
      );
    } else {
      ui.showSnackBar(
        SnackBar(content: Text('Did not increment counter')),
        duration: Duration(seconds: 3),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: Text(widget.title),
      ),
      //register a handler below the scaffold.
      body: EffectHandler(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('You have pushed the button this many times:'),
              Text(
                '$_counter',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
