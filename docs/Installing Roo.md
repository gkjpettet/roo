# Installing Roo

- [Installing The Interpreter](#installing)
	- [On macOs Using Homebrew](#homebrew)
	- [On Windows Using Scoop](#scoop)
	- [Using Binaries](#binaries)
		- [macOS and Linux](#binaries-macos-linux)
		- [Windows](#binaries-windows)
	- [From Source](#source)
- [Using The Interpreter](#using-the-interpreter)

---

## <a name="installing"></a>Installing The Interpreter

The Roo intepreter is a command line tool for executing Roo programs. It's cross platform and works on macOS, Windows and both x86 and ARMv7 (and greater) Linux distributions.

### <a name="homebrew"></a>On macOS Using Homebrew

The easiest way to install Roo on a Mac is to use [Homebrew](https://brew.sh/).

```
brew tap gkjpettet/homebrew-roo
brew install roo
```

To make sure that you've always got the latest version of Roo, just run `brew update` in the Terminal. You'll know there's an update available if you see the following:

```
==> Updated Formulae
gkjpettet/roo/roo ✔
```

Then you'll know there's a new version available. To install it simply type `brew upgrade` in the Terminal.

### <a name="scoop"></a>On Windows Using Scoop

If you're using Windows I recommend using [Scoop](https://scoop.sh/) to install Roo. Once You've setup Scoop, simply type the following into the Command Prompt or the Powershell:

```
scoop bucket add roo https://github.com/gkjpettet/scoop-roo
scoop install roo
```

To update Roo run the following commands:

```
scoop update
scoop update roo
```

### <a name="binaries"></a>Using Binaries

If you prefer not to use a package manager on macOS or Windows or you're on Linux then you can run Roo from its provided binary. 


#### <a name="binaries-macos-linux"></a>macOS and Linux

First download the correct release from [Github](https://github.com/gkjpettet/roo/releases). The zip file will contain the following files/folders:

```
roo Libs/
roo
```

Copy these to somewhere within your `$PATH`. Launch the `roo` binary to use the interpreter. If you copy the contents to your `$PATH` then you'll be able to run the interpreter simply by typing `roo` in the Terminal.

#### <a name="binaries-windows"></a>Windows

First download the correct release from [Github](https://github.com/gkjpettet/roo/releases). The zip file will contain the following files/folders:

```
roo Libs/
roo.exe
msvcp120.dll
msvcp140.dll
msvcr120.dll
vccorlib140.dll
vcruntime140.dll
XojoConsoleFramework64.dll
```

Copy these to somewhere within your `$PATH`. Launch the `roo` binary to use the interpreter. If you copy the contents to your `$PATH` then you'll be able to run the interpreter simply by typing `roo.exe` in the Terminal.

### <a name="source"></a>From Source

**Note: Requires a Xojo license**

To successfully build the intepreter you will need the core Roo classes which are maintained in a separate repo: [https://github.com/gkjpettet/roo-core](https://github.com/gkjpettet/roo-core).

Clone this repo and the core classes repo above. The Xojo IDE will likely prompt you to resolve some path issues regarding the core classes so you will have to manually tell the IDE where the core classes are located on your system. After this, build the app from within the Xojo IDE for your platform of choice. Remember to place the `roo` executable in your PATH (and make sure the dependency folder/files are in the same place). The interpreter is written entirely in native Xojo code and no external plugins are required.

The console project for the Roo interpreter contains a number of build scripts. These will fail without some modification on your part.

---

## <a name="using-the-interpreter"></a>Using The Interpreter

After successfully installing the interpreter you should have the `roo` binary at your disposal. For clarity, in the following examples, the `$` denotes the command line prompt.

### Running A Script

Running a script is easy. Just pass, as an argument, to the Roo interpreter the full path to the script to run:

```
$ roo my_program.roo
```

### Using The REPL

It's possible to use the interpreter as a [REPL](https://en.wikipedia.org/wiki/REPL). This allows the execution of Roo commands with immediate response in real time:

```
$ roo
Roo interpreter (v3.0.0)
>>>
```

Just type Roo commands at the prompt (`>>>`) and you'll get immediate output from the Terminal.

### Miscellaneous

You can get basic help from the interpreter with the `-h` flag:

```
$ roo -h
Roo interpreter (v3.0.0)
Usage: roo [option]
roo <file>	: Run a script
roo -h			: Display help
roo -v			: Display the interpreter's version number
```

You can see the current version of the Roo interpreter installed on your system with the `-v` flag:

```
$ roo -v
3.0.0 (10 Mar 2019, revsion 37)
```
