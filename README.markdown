# pyin.vim

Executes Python code in Vim buffers and insert its output.

*pyin.vim* allows you to run Python code pieces and embed its
output in the buffer. It takes a visual selection of Python code from any type of buffer,
runs it with a selected interpreter (CPython, IronPython, Jython or some other Python interpreter)
and then it will append (or replace, depending to the command provided)
the output of the code back to the buffer.

We already have
[Execute Python from within current file](http://vim.wikia.com/wiki/Execute_Python_from_within_current_file)
and it is the inspiration for this plugin.

This plugin does not require `+Python` in Vim,
(which means the Vim itself does not need to be compiled with Python support)
so it is possible to use this plugin with [Jython](http://www.jython.org/)
and [IronPython](http://ironpython.net/) interpreters as well, since it only executes them from command line.
So, it is suitable for Vim installations in more restricted environments.

Home page:
[https://github.com/caglartoklu/pyin.vim](https://github.com/caglartoklu/pyin.vim)


# Changelog

See the change log from [git commits](https://github.com/caglartoklu/pyin.vim/commits/master).


# Installation

For [vim-plug](https://github.com/junegunn/vim-plug) users:

```viml
Plug 'caglartoklu/pyin.vim'
```

For [Vundle](https://github.com/VundleVim/Vundle.vim) users:

```viml
Plugin 'caglartoklu/pyin.vim'
```

For [Pathogen](https://github.com/tpope/vim-pathogen) users:

```bat
cd ~/.vim/bundle
git clone git://github.com/caglartoklu/pyin.vim
```

For all other users, simply drop the `pyin.vim` file to your
`plugin` directory.


## Supported Environments
- [Vim](http://www.vim.org/) (no `+Python` required)
- [Python](https://www.python.org/) (aka CPython, default)
- [IronPython](http://ironpython.net/)
- [Jython](http://www.jython.org/)
- Tested on Windows 10



# Commands

## `PivExecuteAndAppend`
   takes the Python code, runs it, and appends its output to the buffer.

## `PivExecuteAndReplace`
   takes the Python code, runs it, and replaces the Python code with
   its output.

## `PivMakePile` and `MakePile`
Launches `makepile.py` if found.
Not to be confused with common makefiles.

## `PivRunBuffer`
Saves the buffer and runs it with `g:pyinvim_interpreter`.

## `PivPylint`
Launches `pylint` installed into `g:pyinvim_interpreter`.

## `PivPep8`
Launches `pycodestyle` installed into `g:pyinvim_interpreter`.

## `PivAutoPep8`
Saves the buffer and launches `autopep8` installed into `g:pyinvim_interpreter` and reloads the buffer.

## `PivVulture`
Launches `vulture` installed into `g:pyinvim_interpreter`.

## `PivDoc`
Launches `pydoc` for the word under the cursor.
The results is displayed in another tab in vim.

## `PivDocInput`
Asks the user about a keyword and launches `pydoc`.



# Configuration
## `g:pyinvim_interpreter`
The path to the Python interpreter. It can be full path to various
Python interpreters such as `ipy.exe`.
default: `'python'`, which assumes that `python` command is defined
on the `PATH` variable.

```viml
let g:pyinvim_interpreter = 'python'
```

## `g:pyinvim_interpreter_options`
Any extra options to be passed to the Python interpreter.
default: `''`.

```viml
let g:pyinvim_interpreter_options = ''
```

## `g:pyinvim_delete_temp_files`
Since this plugin creates temp files, this options makes sure it
gets deleted.
default: `1`.

```viml
let g:pyinvim_delete_temp_files = 1
```

### `g:pyinvim_left_align`
Removes unnecessary leading whitespace to prevent errors raised
by the Python interpreter.
default: `1`.

```viml
let g:pyinvim_left_align = 1
```

## `g:pyinvim_before_lines`
List of lines that will be added to the top of the Python code to be executed.
Frequently used import statements can be used here.
These lines are added before the user code.

```viml
let pyinvim_before_lines = []
call add(pyinvim_before_lines, '# -*- coding: utf-8 -*-')
call add(pyinvim_before_lines, 'import os')
call add(pyinvim_before_lines, 'import pprint')
call add(pyinvim_before_lines, 'pp = pprint.PrettyPrinter(depth=6)')
let g:pyinvim_before_lines = pyinvim_before_lines
```

## `g:pyinvim_after_lines`
List of lines that will be added to the bottom of the Python code to be executed.
These lines are added after the user code.

```viml
let pyinvim_after_lines = []
call add (pyinvim_after_lines, 'print "# done"')
let g:pyinvim_after_lines = pyinvim_after_lines
```

## `g:pyinvim_gotolinewhendone`
The line number or indicator that will be used after running the code.
Some examples are:

```viml
let g:pyinvim_gotolinewhendone = 'start'
let g:pyinvim_gotolinewhendone = 'finish'
let g:pyinvim_gotolinewhendone = '10'
```

## Example vimrc configuration

```viml
" { Plugin 'caglartoklu/pyin.vim'
    let g:pyinvim_interpreter = 'python'
    " let g:pyinvim_interpreter = 'C:\Python27\python.exe'
    " let g:pyinvim_interpreter = 'C:\bin\IronPython\ipy.exe'
    let g:pyinvim_interpreter_options = ''
    let g:pyinvim_delete_temp_files = 0
    let g:pyinvim_left_align = 1

    let pyinvim_before_lines = []
    call add(pyinvim_before_lines, '# -*- coding: utf-8 -*-')
    call add(pyinvim_before_lines, 'import os')
    call add(pyinvim_before_lines, 'import pprint')
    call add(pyinvim_before_lines, 'pp = pprint.PrettyPrinter(depth=6)')
    let g:pyinvim_before_lines = pyinvim_before_lines

    let pyinvim_after_lines = []
    call add(pyinvim_after_lines, 'print "# done"')
    let g:pyinvim_after_lines = pyinvim_after_lines

    let g:pyinvim_gotolinewhendone = 'start'
" }
```



# Examples about `PivExecuteAndAppend` and `PivExecuteAndReplace`

## Example1
Let's say we have a buffer with this text.

```python
print "1"
print "2"
```

Simply, visual-select them. To do that,
jump to the first of these two lines in normal mode.
Select these two lines with `SHIFT-v` (or `v`) and then `j` keys as usual.

Now press `:` and enter `PyinvimExecuteAndAppend`.
The plugin will copy the Python code to a temp file, run it,
catch its output and append to the buffer.

Note that the type of the buffer does not have to `python`.
It can be anything, text, rst, or even any other programming
language, such as Java. The only important thing is, just text.


## Example2
Try this code, which would be more useful:

```python
for i in range(6):
    print "  i:", i
```

![PyinvimExecuteAndAppend1](https://raw.github.com/caglartoklu/pyin.vim/media/images/pyinvim_executeappend.png)


## Example3
Let's say we have this one, and we want to execute the
3 lines of code inside the `while` loop.

```python
while keepgoing:  # indent level: 0
    print "1"     # indent level: 1
    print "2"     # indent level: 1
    print "3"     # indent level: 1
```

So, our selection for the code above is:

```python
    print "1"     # indent level: 1
    print "2"     # indent level: 1
    print "3"     # indent level: 1
```

Since there are leading whitespace characters,
it would not work on a Python interpreter.

But, *pyin.vim* aligns the code to the left.
That is, it actually runs this code:

```python
print "1"     # indent level: 0
print "2"     # indent level: 0
print "3"     # indent level: 0
```

with success.


## Example4
First, execute this command:

```viml
let g:pyinvim_interpreter='C:\bin\IronPython\ipy.exe'
```

It will point the `ipy.exe` (the Python interpreter of IronPython).

Then, run the following code piece:

```python
import clr
clr.AddReference("System")
import System
System.Console.WriteLine('ddd')
print dir(System.Console)[0:3]
```

It will append:

```
ddd
['BackgroundColor', 'Beep', 'BufferHeight']
```



# Guide

## How to see the Python file?
In some cases (for debugging purposes most of the time),
you would need to see the final Python file that has been sent to the interpreter.

First things first, make sure you have the following line in your `VIMRC`:

```viml
let g:pyinvim_delete_temp_files = 0
```

If you don't have it, add it and restart vim so that the setting is read.

Then, you can raise a simple exception by executing the following code snippet:

```python
print 1/0
```

The output of the Python interpreter will be seen in the buffer with the full path to the file:

```
Traceback (most recent call last):
  File "C:\Users\user1\AppData\Local\Temp\VIM4108.tmp", line 5, in <module>
    print 1/0
ZeroDivisionError: integer division or modulo by zero
```

Simply browse to the temp diretory and inspect the file.


# License

Licensed under the Apache License, Version 2.0.
See the
[LICENSE](https://github.com/caglartoklu/pyin.vim/blob/master/LICENSE) file.
