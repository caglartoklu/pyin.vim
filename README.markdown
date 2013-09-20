# pyin.vim

Executes Python code in Vim buffers and insert its output.

*pyin.vim* allows you to run Python code pieces and embed its
output in the buffer. It takes a visual selection of Python code,
and then it will append (or replace, depending to the command provided)
the output of the code to the buffer.

We already have
[Execute Python from within current file](http://vim.wikia.com/wiki/Execute_Python_from_within_current_file)
and it is the inspiration for this plugin.

This plugin does not require `+Python` in Vim,
(which means the Vim itself does not need to be compiled with Python support)
and it supports [Jython](http://www.jython.org/)
and [IronPython](http://ironpython.net/) interpreters as well.
So, it is suitable for Vim installations in
more restricted environments.

Home page:
[https://github.com/caglartoklu/pyin.vim](https://github.com/caglartoklu/pyin.vim)


## Changelog

- 2013-09-20
  - First version.


## Installation

For [Vundle](https://github.com/gmarik/vundle) users:

    Bundle 'caglartoklu/pyin.vim'

For [Pathogen](https://github.com/tpope/vim-pathogen) users:

    cd ~/.vim/bundle
    git clone git://github.com/caglartoklu/pyin.vim

For all other users, simply drop the `pyin.vim` file to your
`plugin` directory.


## Supported Environments
- Vim (no `+Python` required)
- Python (aka CPython, default)
- IronPython
- Jython
- Tested on Windows 7 and Ubuntu 12.04 LTS


## Usage
This plugin defines two commands:

- `PyinvimExecuteAndAppend`
   takes the Python code, runs it, and appends its output to the buffer.
- `PyinvimExecuteAndReplace`
   takes the Python code, runs it, and replaces the Python code with
   its output.


### Example1
Let's say we have a buffer with this text.

    print "1"
    print "2"

Simply, visual-select them. To do that,
jump to the first of these two lines in normal mode.
Select these two lines with `SHIFT-v` (or `v`) and then `j` keys as usual.

Now press `:` and enter `PyinvimExecuteAndAppend`.
The plugin will copy the Python code to a temp file, run it,
catch its output and append to the buffer.

Note that the type of the buffer does not have to `python`.
It can be anything, text, rst, or even any other programming
language, such as Java. The only important thing is, just text.


### Example2
Try this code, which would be more useful:

    for i in range(6):
        print "  i:", i


### Example3
Let's say we have this one, and we want to execute the
3 lines of code inside the `while` loop.

    while keepgoing:  # indent level: 0
        print "1"     # indent level: 1
        print "2"     # indent level: 1
        print "3"     # indent level: 1

So, our selection for the code above is:

        print "1"     # indent level: 1
        print "2"     # indent level: 1
        print "3"     # indent level: 1

Since there are leading whitespace,
it would not work on a Python interpreter.

But, *pyin.vim* aligns the code to the left.
That is, it actually runs this code:

    print "1"     # indent level: 0
    print "2"     # indent level: 0
    print "3"     # indent level: 0

with success.


### Example4
First, execute this command:

    let g:pyinvim_interpreter='C:\bin\IronPython\ipy.exe'

It will point the `ipy.exe` (the Python interpreter of IronPython).

Then, run the following code piece:

    import clr
    clr.AddReference("System")
    import System
    System.Console.WriteLine('ddd')
    print dir(System.Console)[0:3]

It will append:

    ddd
    ['BackgroundColor', 'Beep', 'BufferHeight']


## Configuration
`g:pyinvim_interpreter`
The path to the Python interpreter. It can be full path to various
Python interpreters such as `ipy.exe`.
default: `'python'`, which assumes that `python` command is defined
on the `PATH` variable.

`g:pyinvim_interpreter_options`
Any extra options to be passed to the Python interpreter.
default: `''`.

`g:pyinvim_delete_temp_files`
Since this plugin creates temp files, this options makes sure it
gets deleted.
default: `1`.

`g:pyinvim_left_align`
Removes unnecessary leading whitespace to prevent errors raised
by the Python interpreter.
default: `1`.


## License
Licensed with 2-clause license ("Simplified BSD License" or "FreeBSD License").
See the LICENSE file.


## Contact Info
You can find me on
[Google+](https://plus.google.com/108566243864924912767/posts)

Feel free to send bug reports, or ask questions.
