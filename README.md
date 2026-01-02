**Show dialogs, toasts, bottom sheets, snackbars, modals and more from anywhere without "magic" decoupling from context.**

# How it works

This package works by ensuring that there is always a single widget in the widget tree, this widget is called `EffectHandler`, its purpose is to handle (hence the name) any ui side effect that the global instance `UICenter.instance` wants to display.

## Effect Handler

Add an `EffectHandler` widget directly below the scaffold of every page in your app (or at least the pages that show dialogs, sheets, toasts, etc.).

```dart
@override
Widget build(BuildContext context){
    return Scaffold(
        body: EffectHandler(
            child: MyBody(),
        ),
    );
}
```

_Note: `EffectHandler` can actually be placed anywhere in the widget tree, but for consistency it is best to add it directly below the scaffold since that is the highest it can be while supporting all material ui side effects._

## UI center

This is where you can create and show ui effects, it works like this:

```dart
//Get the UICenter instance from anywhere in your app
UICenter get ui => UICenter.instance;


void aFunction(){
    //Show a snackbar on the current scaffold
    ui.showSnackbar(
      SnackBar(content:Text('aFunction was activated')),
      //this makes snackbar disappear after two seconds
      duration: Duration(seconds: 2),
    );
}
```

The ui center can display the following effects by default:

```dart
//effects that can return a value (request effects)
var val = await ui.showDialog(MyDialog())
var val = await ui.showModalBottomSheet(MyModalSheet())
var val = await ui.showCupertinoDialog(MyDialog())
var val = await ui.showCupertinoModalPopup(MyModal())
var val = await ui.showCupertinoSheet(MySheet())

//effects that are fire and forget (send effects)
ui.showBottomSheet(MySheet())
ui.showSnackbar(Snackbar(...))
ui.showMaterialBanner(MaterialBanner(...))
```

## Creating more ui effects

It is easy to add more effects using extensions, an example would be implementing a navigation effect using `go_router`.

```dart
extension NavigatorUICenter on UICenter {
  /// Navigate to a location using go_router
  void navigateTo(String location) => send(
    SendEffect(
      // our functionality goes here
      callback: (context) => context.go(location),
      // debug properties will be very usefull when testing.
      debugProperties: {
        'caller' : 'navigateTo',
        'location' : location,
      },
    ),
  );
}
```

if you need to implement an effect that can return a value, use `request` and `RequestEffect` instead.

## Testing

Because UI effects decouple the UI from the widget tree, it is also possible to test business logic that triggers UI effects without a full Flutter widget test.

For this, you can use the `InspectableEffectHandler`.

Here is an example of how to use it:

```dart
test('Example test', () async {
  // Create an inspectable handler.
  final handler = InspectableEffectHandler();

  //we can declaratively define a value to be returned for the request
  handler.whenRequest<bool>(answer: true);

  final value = await ui.showDialog<bool>(MyDialog());

  expect(value, isTrue);

  // We can get events from the queue of request effects that occured.
  final event = await handler.requests.next;

  // We can inspect the dialog's properties:
  expect(event.debugProperties['caller'], 'showDialog');
  // Debug properties have the same name as the args in the function.
  expect(event.debugProperties['dialog'], isA<MyDialog>());

  //Next to the request effect queue we can also get the sends queue and regular streams:
  final sendEvent = await handler.sends.next;
  final requestStream = handler.requestStream;
  final sendStream = handler.sendStream;

  // Since only one handler is supposed to be registered at a time, we dispose it after.
  handler.dispose();
});
```

Testing like this becomes especially useful when you are testing notifiers, blocs, or whatever state management solution you use.

## Contributing

This package is MIT licenced and open to any contributions, feel free to open issues, make feature suggestions or submit prs on github.
