# Roo
The reference command line interpreter for the Roo programming language

## Table of contents
1. [Installation](#installation)

## The Roo programming language
Roo is a cross-platform dynamically-typed interpreted open source scripting language which takes inspiration from Ruby (everything is an object) and Javascript. It supports both object-oriented and functional programming approaches and includes closures. The reference interpreter is `roo` which is written in [Xojo][xojo].

## <a id="installation">Installation</a>
To play with Roo you'll need to install the `roo` interpreter. This is a command line tool that runs your source code. It can also be used as a REPL (much like Ruby's `irb` command). To install, you have a few choices:

### 1. Use a package manager (easiest)
Simple installation with Homebrew and Scoop is offered for macOS and Windows users.

**macOS**  
If you're using macOS you can use the excellent [Homebrew][homebrew] package manager to quickly install Roo:
```
brew tap gkjpettet/homebrew-roo
brew install roo
```

You can make sure that you've always got the latest version of Roo by running `brew update` in the Terminal. You'll know there's an update available if you see the following:

```bash
==> Updated Formulae
gkjpettet/roo/roo ✔
```

Then you'll know there's a new version available. To install it simply type `brew upgrade` in the Terminal. 

**Windows**  
If you're using Windows I recommend using [Scoop][scoop] to install Roo. Once You've setup Scoop, simply type the following into the Command Prompt or the Powershell:

```bash
scoop bucket add roo https://github.com/gkjpettet/scoop-roo
scoop install roo
```

To update Roo run the following commands:

```bash
scoop update
scoop update roo
```

### 2. Install the precompiled binary and its dependencies
If you can't/don't want to use a package manager then I provide precompiled binaries for macOS (64-bit), Windows (32/64-bit) and x86 Linux (64-bit). Essentially just make sure that you install the `roo` binary and all its dependencies (included in the download) within your system's PATH. The Mac and Linux versions contain one file and one folder:

```bash
roo
[roo Libs]
```

The Windows version includes several files and a folder:

```bash
msvcp120.dll
msvcp140.dll
msvcr120.dll
roo.exe
[roo Libs]
vccorlib140.dll
vcruntime140.dll
XojoConsoleFramework64.dll
```

I use a Mac and if I wasn't using Homebrew I would place `roo` and `roo Libs/` in `/usr/local/bin`. You can grab the required files from the [releases page][releases].

### 3. Build the intepreter from source
**Note: Requires a Xojo license and MBS plugin license**

Simply clone this repo and build the app from within the Xojo IDE for your platform of choice. Remember to place the `roo` executable in your PATH (and make sure the dependency folder/files are in the same place).

Once the `roo` interpreter is installed, you can start a REPL session by typing `roo` in the Terminal. This will give you a prompt and allow you to enter Roo code line by line and have it interpreted as you enter it. Good for playing around. It's worth noting that you don't have to terminate statements with semicolons a REPL session. To run a script, simply type `roo [script.roo]` where `script.roo` is the full path to the script to run.

Whilst there is no interactive debugger for Roo (yet), `roo` does provide reasonably accurate and helpful error messages if a problem is encountered either during program lexing, parsing or execution.

To quit a REPL session type `CTRL-C` or `CTRL-D` or `CTRL-X` (depending on your operating system). Or you can simply use the global `quit` statement.

[homebrew]: https://brew.sh
[scoop]: https://scoop.sh
[snaps]: https://snapcraft.io
[xojo]: https://xojo.com
