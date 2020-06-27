# Embedding Roo

Whilst Roo is a capable scripting language in its own right and can be used from the command line it was originally developed to function as a replacement for Xojo's native scripting language - [XojoScript](https://docs.xojo.com/index.php/XojoScript).

Roo is not as high performance as XojoScript. If you want to add scriptability to your Xojo apps that require computationally intense routines (e.g: image manipulation) then XojoScript may still be a better fit for you. Where Roo excels is in its expressiveness and its possession of powerful intrinsic data types such as Hashes, Regexes and native file manipulation.

If you're only planning on using the Roo command line interpreter, feel free to skip this section.

- [Adding Roo To A Xojo App](#adding-to-app)
- [Using Roo In Your App](#using)
	- [Events](#using-events)
	- [Adding Handlers](#adding-handlers)
	- [Running The Interpreter](#running-the-interpreter)
- [Miscellaneous](#misc)
	- [Protected Locations In FileSystem Safe Mode](#misc-protected)
		- [All Operating Systems](#misc-protected-all)
		- [macOS](#misc-protected-macos)
		- [Windows](#misc-protected-windows)
		- [Linux](#misc-protected-linux)

We all know a picture is worth a thousand words. Well an example app is probably worth ten thousand words. For a desktop app using Roo, check out the open source [Roo IDE](https://github.com/gkjpettet/roo-ide). For a command line app using Roo, checking out the [reference CLI app](https://github.com/gkjpettet/roo) should help.

---

## <a name="adding-to-app"></a>Adding Roo To A Xojo App

The prerequisites to using Roo as a scripting language for you own Xojo app are the same as for building the Roo command line tool from source, namely:

1. The Roo core classes source code. These can be found within the `src/core/Roo` folder in the [repo](https://github.com/gkjpettet/roo) for the command line Roo reference interpreter
2. A valid [Xojo](https://xojo.com) console license

Drag the entire contents of the `Roo` folder from the repo into your Xojo project. Roo has been tested on macOS, 64-bit Windows, 64-bit Linux and the Raspberry Pi (running Raspbian). I haven't tested it in a Xojo Web project but it should work just fine. Roo will not work in iOS projects as it relies on Xojo's `String`, `Variant` and `RegEx` classes which are compatible with iOS at present.

---

## <a name="using"></a>Using Roo In Your App

Once the required classes have been imported into your project, you'll need to create a `RooInterpreter` instance:

```xojo
// We shall assume `Interpreter` is a property on your App instance.
// In the App.Open event put:
Interpreter = New RooInterpreter
```

### <a name="using-events"></a>Events

The `RooInterpreter` class provides a number of events that you can use. Since we've added the `RooInterpreter` via code, we'll need to use Xojo's `AddHandler` keyword to link the events of the interpreter to methods in our app. To add a handler for an event, the method's signature must match the event's signature with the addition of the sending interpreter as the first argument. The `RooInterpreter` class has 6 events. You do not have to handle any of the events if you don't want to. You should consider at least implementing the `Print` and `ErrorOccurred` events however as otherwise it's not possible to display the output of a script or handle any runtime errors. The events are listed below in alphabetical order:

- [AllowNetworkAccess](#using-events-allownetworkaccess)
- [DeletionPrevented](#using-events-deletionprevented)
- [ErrorOccurred](#using-events-erroroccurred)
- [Input](#using-events-input)
- [NetworkAccessed](#using-events-networkaccessed)
- [Print](#using-events-print)

#### <a name="using-events-allownetworkaccess"></a>AllowNetworkAccess(url As String) As Boolean

Whenever a Roo script attempts to make a network call (i.e. a HTTP or HTTPS request) this event is fired. It provides the target URL. If you want to allow the script access to this URL then return `True`. Returning `False` for a particular (or any) URL or not handling this event at all will prevent network access and cause the interpreter's `RuntimeError` event to fire.

#### <a name="using-events-deletionprevented"></a>DeletionPrevented(f As FolderItem, where As RooToken)

This event is fired when the interpreter prevents a file or folder from being deleted. This occurs if a script attempts to delete a file or folder that is regarded by the interpreter as "protected" **and** the interpreter has its `FileSystemSafeMode` property set to `True` (the default). See [here](#misc-protected) for the locations that are considered protected by the interpreter. This event serves to inform you as the Xojo app developer that there may be a malicious or poorly written script running.

#### <a name="using-events-input"></a>Input(prompt As String) As String

When a script invokes either the global `input()` or global `input_value()` functions, this event is fired. It provides the prompt that the script wants displayed to the user as a `String`. It expects a Xojo `String` to be returned from its delegate method. This returned `String` will be converted either to a Roo runtime `Text` object in the calling script (in the case of `input()` or will be converted into either a `Text`, `Number`, `Boolean` or `Nothing` Roo runtime object in the case of `input_value()`. How you choose to request input from the user is up to you.

#### <a name="using-events-networkaccessed"></a>NetworkAccessed(url As String, status As Integer)

This event is fired whenever a script has accessed the network. It provides the URL that was accessed and the HTTP status code that resulted from the network call.

#### <a name="using-events-print"></a>Print(s As String)

The script is telling the interpreter to display the passed `String` `s` to the user. How you choose to display this is up to you.

#### <a name="using-events-erroroccurred"></a>ErrorOccurred(type As RooInterpreter.ErrorType, where As RooToken, message As String)

An error has occurred during some phase of script execution (either scanning, parsing, semantic analysis or during runtime). The `type` property is an enumeration specifying when the error occurred (e.g: `ErrorType.Scanner`). The event provides the token causing the error (which contains information such as the line number) as well as a human-readable English message describing the error.

### <a name="adding-handlers"></a>Adding Handlers

Now we now what events the interpreter fires we can decide which ones we are interested in. As mentioned above, as a bare minimum you'll probably want to be notified when a script calls `print()`, `input()` or `input_value()` and if a runtime error occurs. We'll create three methods called `PrintMethod`, `InputMethod` and `ErrorMethod` with the following signatures in our app:

```xojo
Public Sub PrintMethod(sender As RooInterpreter, what As String)
	// Just display a message box with the String to print.
	MsgBox(what)
End Sub

Public Function InputMethod(sender As RooInterpreter, prompt As String) As String
	// Let's assume we have another method that somehow gathers String input
	// from the user for us and puts it into a variable called `userInput`.
	Return userInput
End Function

Public Sub ErrorMethod(sender As RooInterpreter, type As RooInterpreter.ErrorType, where As RooToken, message As String)
	// Feel free to do what you like with this information.
	// I'm just going to display a message box with the error message and the line number.
	MsgBox("Error on line " + Str(where.Line) + ": " + message)
End Sub
```

Once we have created these methods, we'll "attach" them to the relevant events on our interpreter instance:

```xojo
Interpreter = New Interpreter
AddHandler Interpreter.ErrorOccurred, AddressOf ErrorMethod
AddHandler Interpreter.Print, AddressOf PrintMethod
AddHandler Interpreter.Input, AddressOf InputMethod
```

### <a name="running-the-interpreter"></a>Running The Interpreter

Now that the interpreter is all setup, all that's left to do is pass it some Roo code and let it start interpreting. The `RooInterpreter` class has an `Interpret()` method that takes source code in one of the following three formats:

1. Raw source code as a Xojo `String`
2. A text file `FolderItem` containing Roo source code
3. An abstract syntax tree in the form of an array of `RooStmt` objects

If you choose to pass either a `String` or `FolderItem` argument to the `Interpret()` method you can optionally pass a second `Boolean` argument (`preserveState`). This defaults to `False` but if passed a `True` value then the interpreter will **not** reset itself between interpretations. This allows you to use the interpreter as a REPL.

```xojo
// Pass a String.
Interpreter.Interpreter("print('Hello World!')")

// Pass a file.
Dim f As FolderItem = GetOpenFolderItem("")
If f <> Nil Then Interpreter.Interpret(f)
```

---

## <a name="misc"></a>Miscellaneous

Below is additional information on implementation details of the Roo interpreter which don't fit neatly into the sections above.

### <a name="misc-protected"></a>Protected Locations In FileSystem Safe Mode

Below are lists (operating system-specific) of the Xojo `SpecialFolder` locations that Roo considers "protected" and will not delete if asked to by a script if the interpreter's `FileSystemSafeMode` property is set to `True`.

#### <a name="misc-protected-all"></a>All Operating Systems

- `SpecialFolder.ApplicationData`
- `SpecialFolder.Desktop`
- `SpecialFolder.Documents`
- `SpecialFolder.Movies`
- `SpecialFolder.Music`
- `SpecialFolder.Pictures`
- `SpecialFolder.UserHome`

#### <a name="misc-protected-macos"></a>macOS

- `SpecialFolder.Applications`
- `SpecialFolder.Bin`
- `SpecialFolder.Etc`
- `SpecialFolder.Favorites`
- `SpecialFolder.Fonts`
- `SpecialFolder.Home`
- `SpecialFolder.Library`
- `SpecialFolder.Mount`
- `SpecialFolder.Preferences`
- `SpecialFolder.Printers`
- `SpecialFolder.SBin`
- `SpecialFolder.SharedApplicationData`
- `SpecialFolder.SharedDocuments`
- `SpecialFolder.SharedPreferences`
- `SpecialFolder.System`
- `SpecialFolder.UserBin`
- `SpecialFolder.UserLibrary`
- `SpecialFolder.UserSBin`

#### <a name="misc-protected-windows"></a>Windows

- `SpecialFolder.Applications`
- `SpecialFolder.Extensions`
- `SpecialFolder.Favorites`
- `SpecialFolder.Fonts`
- `SpecialFolder.Printers`
- `SpecialFolder.SharedApplicationData`
- `SpecialFolder.SharedDocuments`
- `SpecialFolder.System`
- `SpecialFolder.Windows`

#### <a name="misc-protected-linux"></a>Linux

- `SpecialFolder.Bin`
- `SpecialFolder.Etc`
- `SpecialFolder.Home`
- `SpecialFolder.Library`
- `SpecialFolder.Mount`
- `SpecialFolder.SBin`
- `SpecialFolder.UserBin`
- `SpecialFolder.UserLibrary`
- `SpecialFolder.UserSBin`