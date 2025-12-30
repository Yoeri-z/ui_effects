Show dialogs, toasts and bottom sheets, snackbars, modals and more from anywhere without "magic" decoupling from context.

# Getting started

Add the package to your project:
`flutter pub add ui_effects`

# How it works

## Effect Handler

Add an `EffectHandler` widget directly below the scaffold of every page (or only the pages that show dialogs, sheets, toasts, etc.).

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

Note: `EffectHandler`s can actually be placed anywhere in the widget tree, but for consistency it is best to add it directly below the scaffold since that is the highest it can be while supporting all built in features.

This handler will be handling (hence the name) any incoming ui effects: dialogs, bottom sheets, modals toasts, or something custom.
This handler is where the context comes from! This is very important to realize, the context does not magically dissapear, it is the context at the location of the handler. This is especially crucial to know if you want to implement a custom effect.

## UI center

This is where you can create and show ui effects, it works like this:

```dart
//Get the effect instance from anywhere in your app
UICenter get ui => UICenter.instance;


void aFunction(){
    //Show a toast on the currently active page, provided it has an EffectHandler
    ui.showToast(message: 'A Function was called', toastType: ToastType.succes);
}
```

The ui center can display the following effect by default:

```dart
ui.showDialog(MyDialog())
//this package also provides a new ui effect called toast
//easier to manage than snackbar or material banner
ui.showToast(message: ..., toastType: ...)
ui.showBottomSheet(MySheet())
ui.showModalBottomSheet(MyModalSheet())
ui.showCupertinoDialog(MyDialog())
ui.showCupertinoModalPopup(MyModal())
ui.showCupertinoSheet(MySheet())
ui.showSnackbar(Snackbar(...))
ui.showMaterialBanner(MaterialBanner(...))

//these are lower level methods to create more complex or custom ui effects
//ui.request shows an ui that can be popped with a value
ui.request(RequestEffect(...))
//ui.send can run effects that dont return a value.
ui.send(SendEffect(...))
```

## Creating more ui effects

It is easy to add more effects to this package using extensions, an example would be implementing a navigate to effect using `go_router`.

```dart
extension NavigatorUICenter on UICenter {
  /// Navigate to a location using [GoRouter]
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

having to both call `send` and `SendEffect` seems a bit double, this is a remnant of older versions of the package and might be changed in the future.

## Testing

Because ui effects somewhat decouple the ui from the widget tree, it is also possible to do tests without actually running the flutter framework.

```dart
test('Example test', ()async{
    // create an inspectable handler
    final handler = InspectableEffectHandler();

    final value = ui.showDialog(MyDialog())

    //Dialogs "request" data, so we await the next request
    final event = await handler.requests.next;

    // we can inspect the dialogs properties like so
    // debug properties have the same name as the args in the function
    expect(event.debugProperties['caller'], 'showDialog')
    expect(event.debugProperties['dialog'], isA(MyDialog))

    //we can complete the event with a value, simulating a dialog close
    event.complete(expectedValue)

    //The dialog should have completed with the value now.
    expect(await value, expectedValue)

    //since only one handler is supposed to registered at a time, we dispose it after.
    handler.dispose()
})
```

Testing like this becomes especially usefull when your are testing notifiers, blocs, signals or whatever state management solution you use.
