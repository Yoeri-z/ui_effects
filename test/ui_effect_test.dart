import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_effects/ui_effects.dart';

UICenter get ui => UICenter.instance;

class MaterialSetupWidget extends StatelessWidget {
  const MaterialSetupWidget({super.key, required this.withScaffold});

  final bool withScaffold;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: withScaffold
          ? Scaffold(body: EffectHandler(child: Placeholder()))
          : EffectHandler(child: Placeholder()),
    );
  }
}

class CupertinoSetupWidget extends StatelessWidget {
  const CupertinoSetupWidget({super.key, required this.withScaffold});

  final bool withScaffold;

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      home: withScaffold
          ? CupertinoPageScaffold(child: EffectHandler(child: Placeholder()))
          : EffectHandler(child: Placeholder()),
    );
  }
}

void main() {
  group('Material', () {
    testWidgets('showDialog shows a dialog', (tester) async {
      await tester.pumpWidget(MaterialSetupWidget(withScaffold: false));

      ui.showDialog(Dialog());

      await tester.pumpAndSettle();
      final dialogFinder = find.byType(Dialog);

      expect(dialogFinder, findsOneWidget);
    });

    testWidgets('showModalBottomSheet shows a bottom sheet', (tester) async {
      await tester.pumpWidget(MaterialSetupWidget(withScaffold: false));
      final key = ValueKey('widget');

      ui.showModalBottomSheet(Placeholder(key: key));

      await tester.pumpAndSettle();
      final sheetFinder = find.byKey(key);

      expect(sheetFinder, findsOneWidget);
    });

    testWidgets('showBottomSheet shows a bottom sheet', (tester) async {
      await tester.pumpWidget(MaterialSetupWidget(withScaffold: true));
      final key = ValueKey('widget');

      ui.showBottomSheet(
        BottomSheet(
          onClosing: () {},
          builder: (context) => Placeholder(key: key),
        ),
      );

      await tester.pumpAndSettle();
      final sheetFinder = find.byKey(key);

      expect(sheetFinder, findsOneWidget);
    });

    testWidgets(
      'showBottomSheet shows a bottom sheet and dissapears after duration',
      (tester) async {
        await tester.pumpWidget(MaterialSetupWidget(withScaffold: true));
        final key = ValueKey('widget');

        ui.showBottomSheet(
          BottomSheet(
            onClosing: () {},
            builder: (context) => Placeholder(key: key),
          ),
          duration: Duration(seconds: 2),
        );

        await tester.pumpAndSettle();
        final sheetFinder = find.byKey(key);

        expect(sheetFinder, findsOneWidget);

        await tester.pump(const Duration(seconds: 2));
        await tester.pumpAndSettle();

        expect(sheetFinder, findsNothing);
      },
    );

    testWidgets('showSnackbar shows a snackbar', (tester) async {
      await tester.pumpWidget(MaterialSetupWidget(withScaffold: true));
      final key = ValueKey('widget');

      ui.showSnackBar(SnackBar(key: key, content: Placeholder()));

      await tester.pumpAndSettle();
      final snackbarFinder = find.byKey(key);

      expect(snackbarFinder, findsOneWidget);
    });

    testWidgets(
      'showSnackbar shows a snackbar that dissapears after duration',
      (tester) async {
        await tester.pumpWidget(MaterialSetupWidget(withScaffold: true));
        final key = ValueKey('widget');

        ui.showSnackBar(
          SnackBar(key: key, content: Placeholder()),
          duration: Duration(seconds: 2),
        );

        await tester.pumpAndSettle();
        final snackbarFinder = find.byKey(key);

        expect(snackbarFinder, findsOneWidget);

        await tester.pump(Duration(seconds: 2));
        await tester.pumpAndSettle();

        expect(snackbarFinder, findsNothing);
      },
    );

    testWidgets('showMaterialBanner shows a materialbanner', (tester) async {
      await tester.pumpWidget(MaterialSetupWidget(withScaffold: true));
      final key = ValueKey('widget');

      ui.showMaterialBanner(
        MaterialBanner(
          key: key,
          content: Placeholder(),
          actions: [TextButton(onPressed: () {}, child: Text('test'))],
        ),
      );

      await tester.pumpAndSettle();
      final bannerFinder = find.byKey(key);

      expect(bannerFinder, findsOneWidget);
    });

    testWidgets(
      'showMaterialBanner shows a materialbanner that dissapears after duration',
      (tester) async {
        await tester.pumpWidget(MaterialSetupWidget(withScaffold: true));
        final key = ValueKey('widget');

        ui.showMaterialBanner(
          MaterialBanner(
            key: key,
            content: Placeholder(),
            actions: [TextButton(onPressed: () {}, child: Text('test'))],
          ),
          duration: Duration(seconds: 2),
        );

        await tester.pumpAndSettle();
        final bannerFinder = find.byKey(key);

        expect(bannerFinder, findsOneWidget);

        await tester.pump(Duration(seconds: 2));
        await tester.pumpAndSettle();

        expect(bannerFinder, findsNothing);
      },
    );
  });

  group('Cupertino', () {
    testWidgets('showDialog shows a dialog', (tester) async {
      await tester.pumpWidget(CupertinoSetupWidget(withScaffold: false));
      final key = ValueKey('widget');

      ui.showCupertinoDialog(
        CupertinoAlertDialog(key: key, content: Placeholder()),
      );

      await tester.pumpAndSettle();

      final dialogFinder = find.byKey(key);

      expect(dialogFinder, findsOneWidget);
    });

    testWidgets('showSheet shows a sheet', (tester) async {
      await tester.pumpWidget(CupertinoSetupWidget(withScaffold: false));
      final key = ValueKey('widget');

      ui.showCupertinoSheet(
        CupertinoActionSheet(key: key, title: Text('test')),
      );

      await tester.pumpAndSettle();

      final sheetFinder = find.byKey(key);

      expect(sheetFinder, findsOneWidget);
    });

    testWidgets('showModalPopup shows a modal popup', (tester) async {
      await tester.pumpWidget(CupertinoSetupWidget(withScaffold: false));
      final key = ValueKey('widget');

      ui.showCupertinoModalPopup(
        CupertinoActionSheet(key: key, title: Text('test')),
      );

      await tester.pumpAndSettle();

      final sheetFinder = find.byKey(key);

      expect(sheetFinder, findsOneWidget);
    });
  });

  group('Inspectable handler', () {
    late InspectableEffectHandler handler;

    setUp(() {
      handler = InspectableEffectHandler();
      handler.whenRequest<bool>(answer: true);
    });

    tearDown(() {
      handler.dispose();
    });

    test('showDialog launches request event', () async {
      final result = await ui.showDialog<bool>(
        Placeholder(),
        debugProperties: {'custom': Object()},
      );

      expect(result, isTrue);

      final event = await handler.requests.next;

      expect(event.debugProperties.keys, [
        'caller',
        'dialog',
        'barrierDismissible',
        'barrierLabel',
        'fullscreenDialog',
        'requestFocus',
        'custom',
      ]);

      expect(event.debugProperties['caller'], 'showDialog');
      expect(event.debugProperties['dialog'], isA<Placeholder>());
    });

    test('showModalBottomSheet launches a request event', () async {
      final result = await ui.showModalBottomSheet<bool>(
        Placeholder(),
        debugProperties: {'custom': Object()},
      );

      expect(result, isTrue);

      final event = await handler.requests.next;

      expect(event.debugProperties.keys, ['caller', 'sheet', 'custom']);

      expect(event.debugProperties['caller'], 'showModalBottomSheet');
      expect(event.debugProperties['sheet'], isA<Placeholder>());
    });

    test('showCupertinoDialog launches request event', () async {
      final result = await ui.showCupertinoDialog<bool>(
        Placeholder(),
        debugProperties: {'custom': Object()},
      );

      expect(result, isTrue);

      final event = await handler.requests.next;

      expect(event.debugProperties.keys, [
        'caller',
        'dialog',
        'barrierDismissible',
        'barrierLabel',
        'requestFocus',
        'custom',
      ]);

      expect(event.debugProperties['caller'], 'showCupertinoDialog');
      expect(event.debugProperties['dialog'], isA<Placeholder>());
    });

    test('showCupertinoModalPopup launches request event', () async {
      final result = await ui.showCupertinoModalPopup<bool>(
        Placeholder(),
        debugProperties: {'custom': Object()},
      );

      expect(result, isTrue);

      final event = await handler.requests.next;

      expect(event.debugProperties.keys, [
        'caller',
        'modal',
        'barrierDismissible',
        'requestFocus',
        'custom',
      ]);

      expect(event.debugProperties['caller'], 'showCupertinoModalPopup');
      expect(event.debugProperties['modal'], isA<Placeholder>());
    });

    test('showCupertinoSheet launches request event', () async {
      final result = await ui.showCupertinoSheet<bool>(
        Placeholder(),
        debugProperties: {'custom': Object()},
      );

      expect(result, isTrue);

      final event = await handler.requests.next;

      expect(event.debugProperties.keys, [
        'caller',
        'sheet',
        'enableDrag',
        'custom',
      ]);

      expect(event.debugProperties['caller'], 'showCupertinoSheet');
      expect(event.debugProperties['sheet'], isA<Placeholder>());
    });
    test('showSnackbar launches a send event', () async {
      ui.showSnackBar(
        SnackBar(content: Placeholder()),
        debugProperties: {'custom': Object()},
      );

      final event = await handler.sends.next;

      expect(event.debugProperties.keys, [
        'caller',
        'snackBar',
        'duration',
        'snackBarAnimationStyle',
        'custom',
      ]);

      expect(event.debugProperties['caller'], 'showSnackBar');
      expect(event.debugProperties['snackBar'], isA<SnackBar>());
    });

    test('showBottomSheet launches a send event', () async {
      ui.showBottomSheet(Placeholder(), debugProperties: {'custom': Object()});

      final event = await handler.sends.next;

      expect(event.debugProperties.keys, [
        'caller',
        'sheet',
        'duration',
        'custom',
      ]);

      expect(event.debugProperties['caller'], 'showBottomSheet');
      expect(event.debugProperties['sheet'], isA<Placeholder>());
    });

    test('showMaterialBanner launches a send event', () async {
      ui.showMaterialBanner(
        MaterialBanner(
          content: Placeholder(),
          actions: [TextButton(onPressed: () {}, child: const Text(''))],
        ),
        debugProperties: {'custom': Object()},
      );

      final event = await handler.sends.next;

      expect(event.debugProperties.keys, [
        'caller',
        'banner',
        'duration',
        'custom',
      ]);

      expect(event.debugProperties['caller'], 'showMaterialBanner');
      expect(event.debugProperties['banner'], isA<MaterialBanner>());
    });

    group('whenRequest', () {
      Future<String?> makeFooBarRequest() {
        return ui.request<String>(
          RequestEffect<String>(
            callback: (_) {
              throw UnimplementedError();
            },
            debugProperties: {'foo': 'bar'},
          ),
        );
      }

      test('returns a value based on type', () async {
        handler.whenRequest<String>(answer: 'test');

        final value = await makeFooBarRequest();

        expect(value, 'test');
      });

      test('returns a value based on type and matcher', () async {
        handler.whenRequest<String>(
          matcher: (request) => request.debugProperties['foo'] == 'bar',
          answer: 'test',
        );

        final value = await makeFooBarRequest();

        expect(value, 'test');
      });

      test('throws when not matched', () async {
        handler.whenRequest<String>(
          matcher: (request) => request.debugProperties['foo'] == 'foo',
          answer: 'test',
        );

        expectLater(makeFooBarRequest(), throwsStateError);
      });
    });
  });
}
