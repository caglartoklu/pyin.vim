" -*- vim -*-
" FILE: pyin.vim
" PLUGINTYPE: plugin
" DESCRIPTION: Unobtrusive Python buffer execution and linting commands.
" HOMEPAGE: https://github.com/caglartoklu/pyin.vim
" LICENSE: https://github.com/caglartoklu/pyin.vim/blob/master/LICENSE
" AUTHOR: caglartoklu

" Recommended:
" au BufEnter,BufNew *.py nnoremap <buffer> <F5> : call pyin#PyRunBuffer()<cr>
" au BufEnter,BufNew *.py nnoremap <buffer> <F8> : call pyin#Pylint()<cr>
" au BufEnter,BufNew *.py nnoremap <buffer> <F1> : call pyin#PyDoc()<cr>

" TODO: 5 define F9 (as in Spyder) as execute and append in visual mode:
" draft:
" vnoremap <F9> : exec 'PivExecuteAndAppend'<cr>

" TODO: 5 write a healthcheck function using vim's executable() function.
" TODO: 5 Python 2.x without -m compatibility



if exists('g:loaded_pyinvim') || &cp
    " If it already loaded, do not load it again.
    finish
endif


" mark that plugin loaded
let g:loaded_pyinvim = 1


function! s:SetPyinvimSettings()
    " Set the default settings.

    " Set the interpreter.
    " It can be python, ipy, or jython or even something else.
    " Default is python (Cpython), but it can be switched.
    if !exists('g:pyinvim_interpreter')
        let g:pyinvim_interpreter = 'python'
        " let g:pyinvim_interpreter = 'C:\bin\IronPython\ipy.exe'
    endif

    " Extra options for the interpreter.
    " These will be passed to the interpreter as it is.
    if !exists('g:pyinvim_interpreter_options')
        let g:pyinvim_interpreter_options = ''
    endif

    " Option to delete temp files after.
    if !exists('g:pyinvim_delete_temp_files')
        let g:pyinvim_delete_temp_files = 1
    endif

    " removes the leading whitespace
    if !exists('g:pyinvim_left_align')
        let g:pyinvim_left_align = 1
    endif

    " the lines that will be added before the user source code.
    " it can be any valid Python source code,
    " but these will be probably 'import' statemets.
    if !exists('g:pyinvim_before_lines')
        let g:pyinvim_before_lines = []
    endif

    " any code that will be added after the user source code.
    " it can be any valid Python source code.
    if !exists('g:pyinvim_after_lines')
        let g:pyinvim_after_lines = []
    endif

    " includes the line number to place the cursor
    " when the operation is done.
    " possible values:
    " start, finish, 1, 2, 5 etc
    if !exists('g:pyinvim_gotolinewhendone')
        let g:pyinvim_gotolinewhendone = 'start'
    endif

    " if !exists('g:pyinvim_cmd_spyonde')
    "     let g:pyinvim_cmd_spyonde = g:pyinvim_interpreter . ' -m spyonde '
    " endif

    if !exists('g:pyinvim_cmd_pylint')
        let g:pyinvim_cmd_pylint = g:pyinvim_interpreter . ' -m pylint '
    endif

    if !exists('g:pyinvim_cmd_pep8')
        let g:pyinvim_cmd_pep8 = g:pyinvim_interpreter . ' -m pycodestyle '
    endif

    if !exists('g:pyinvim_cmd_autopep8')
        let g:pyinvim_cmd_autopep8 = g:pyinvim_interpreter . ' -m autopep8 '
    endif

    if !exists('g:pyinvim_cmd_vulture')
        let g:pyinvim_cmd_vulture = g:pyinvim_interpreter . ' -m vulture '
    endif

    if !exists('g:pyinvim_cmd_pydoc')
        let g:pyinvim_cmd_pydoc = g:pyinvim_interpreter . ' -m pydoc '
    endif

endfunction

" Define the settings once.
call s:SetPyinvimSettings()


function! s:GetTempFileNameForSource()
    " Returns a temp file name for the source file.
    return tempname()
endfunction


function! s:Left(haystack, needleLength)
    " Returns some characters at the start of a string
    " from the left side, just like Visual Basic.
    " let x = s:Left("abc", 0)
    " Decho x " ''
    " let x = s:Left("abc", 1)
    " Decho x " 'a'
    " let x = s:Left("abc", 2)
    " Decho x " 'ab'
    " let x = s:Left("abc", 3)
    " Decho x " 'abc'
    " let x = s:Left("abc", 5)
    " Decho x " 'abc'
    return strpart(a:haystack, 0, a:needleLength)
endfunction


function! s:Right(haystack, needleLength)
    " Returns some characters at the end of a string
    " from the right side, just like Visual Basic.
    " let x = s:Right("abc", 0)
    " Decho x " ''
    " let x = s:Right("abc", 1)
    " Decho x " 'c'
    " let x = s:Right("abc", 2)
    " Decho x " 'bc'
    " let x = s:Right("abc", 3)
    " Decho x " 'abc'
    " let x = s:Right("abc", 5)
    " Decho x " 'abc'
    let iStart = strlen(a:haystack) - a:needleLength
    return strpart(a:haystack, iStart, a:needleLength)
endfunction


function! s:Strip(haystack)
    " Strips (or trims) leading and trailing whitespace.
    " http://stackoverflow.com/a/4479072
    " return substitute(a:haystack, '^\s*\(.\{-}\)\s*$', '\1', '')
    return s:LStrip(s:RStrip(a:haystack))
endfunction


function! s:LStrip(haystack)
    let result = ''
    let len = strlen(a:haystack)
    let i = 0
    let stripping_done = 0
    while i < len
        let ch = strpart(a:haystack, i, 1)
        let ch2 = ch
        if stripping_done == 0
            if ch == "\t"
                let ch2 = ''
            elseif ch == ' '
                let ch2 = ''
            else
                let stripping_done = 1
            endif
        endif
        let result = result . ch2
        let i = i + 1
    endwhile
    return result
endfunction


function! s:RStrip(haystack)
    let result = ''
    let len = strlen(a:haystack)
    let i = len
    let stripping_done = 0
    while i >= 0
        let ch = strpart(a:haystack, i, 1)
        let ch2 = ch
        if stripping_done == 0
            if ch == "\t"
                let ch2 = ''
            elseif ch == ' '
                let ch2 = ''
            else
                let stripping_done = 1
            endif
        endif
        let result = ch2 . result
        let i = i - 1
    endwhile
    return result
endfunction


function! s:GetCommonCharacterFromLeft(codeAsList)
    " Returns the common character from left, if exists.
    " let x = s:GetCommonCharacterFromLeft(['a1', 'a2', 'a3'])
    " Decho x " 'a'
    " let x = s:GetCommonCharacterFromLeft(['b1', 'a2', 'a3'])
    " Decho x " ''
    " let x = s:GetCommonCharacterFromLeft(['a1', 'a2', ''])
    " Decho x " ''
    " let x = s:GetCommonCharacterFromLeft(['1', 'a2', 'a3'])
    " Decho x " ''
    let previousChar = s:Left(a:codeAsList[0], 1)
    let commonChar = previousChar
    for aLine in a:codeAsList
        let current = s:Left(aLine, 1)
        if s:Strip(current) != ''
            if current != previousChar
                let commonChar = ''
                break
            endif
        endif
    endfor
    return commonChar
endfunction


function! s:LeftAlign(codeAsList)
    " Removes the common leading whitespace from the code.
    " [' aa', ' bb'] => ['aa', 'bb']
    " ['  aa', ' bb'] => [' aa', 'bb']
    let codeAsList2 = a:codeAsList
    let commonWhiteSpace = ''
    let oneMorePass = 1
    while oneMorePass == 1
        if s:GetCommonCharacterFromLeft(codeAsList2) == ' ' || s:GetCommonCharacterFromLeft(codeAsList2) == "\t"
            let counter = 0
            for aLine in codeAsList2
                let codeAsList2[counter] = s:Right(aLine, strlen(aLine) - 1)
                let counter = counter + 1
            endfor
        else
            let oneMorePass = 0
        endif
    endwhile
    return codeAsList2
endfunction


function! s:OneLine(oneLine)
    " Make sure that the line is stripped first.
    " Then, adds a new line character to this line.
    " :help expr-quote
    " Using RStrip() instead of Strip().
    " Strip() would left align everything, even the function definitions
    " in the before lines, which causes problems obviously.
    let oneLine2 = s:RStrip(a:oneLine) . "\r"
    return oneLine2
endfunction


function! s:OneLineEachItem(someList)
    " Make sure that each line is stripped first.
    " Then, adds a new line character to this line.
    " a:someList is the code as a list.
    let resultList = []
    for item in a:someList
        let item2 = s:OneLine(item)
        call add(resultList, item2)
    endfor
    return resultList
endfunction


function! pyin#RunPythonCode(codeAsList)
    " Writes the a:codeAsList to the tempSourceFileName,
    " runs it with the Python interpreter, and
    " returns the output as a list.
    let tempSourceFileName = s:GetTempFileNameForSource()

    " let codeAsList2 = a:codeAsList
    if g:pyinvim_left_align == 1
        let codeAsList2 = s:LeftAlign(a:codeAsList)
    endif
    let codeAsList2 = s:OneLineEachItem(g:pyinvim_before_lines) + codeAsList2 + s:OneLineEachItem(g:pyinvim_after_lines)

    call writefile(codeAsList2, tempSourceFileName)
    let fullCommand = g:pyinvim_interpreter . ' ' . g:pyinvim_interpreter_options . ' ' . tempSourceFileName
    " let fullCommand = shellescape(fullCommand)
    " Decho fullCommand
    let output = system(fullCommand)
    " TODO: 5 check whether this is \n for all file types (Windows, Mac, Linux)
    let outputAsList = split(output, "\n")

    if g:pyinvim_delete_temp_files == 1
        " Remove the temp source file.
        call delete(tempSourceFileName)
    endif

    return outputAsList
endfunction


function! pyin#RunPythonCodePlain(codeAsList)
    " Writes the a:codeAsList to the tempSourceFileName,
    " runs it with the Python interpreter, and
    " returns the output as a list.
    " Unlike pyin#RunPythonCode, pyin#RunPythonCodePlain does not add before and after lines.
    " TODO: 5 pyin#RunPythonCode and pyin#RunPythonCodePlain has common parts, extract them.
    let tempSourceFileName = s:GetTempFileNameForSource()

    " let codeAsList2 = a:codeAsList
    if g:pyinvim_left_align == 1
        let codeAsList2 = s:LeftAlign(a:codeAsList)
    endif
    " Unlike pyin#RunPythonCode, pyin#RunPythonCodePlain does not execute the following lines:
    " let codeAsList2 = s:OneLineEachItem(g:pyinvim_before_lines) + codeAsList2 + s:OneLineEachItem(g:pyinvim_after_lines)

    call writefile(codeAsList2, tempSourceFileName)
    let fullCommand = g:pyinvim_interpreter . ' ' . g:pyinvim_interpreter_options . ' ' . tempSourceFileName
    " let fullCommand = shellescape(fullCommand)
    " Decho fullCommand
    let output = system(fullCommand)
    let outputAsList = split(output, "\n")

    if g:pyinvim_delete_temp_files == 1
        " Remove the temp source file.
        call delete(tempSourceFileName)
    endif

    return outputAsList
endfunction


function! s:GotoLine(lineStart2, lineFinish2)
    " Moves the cursor to the preferred line when the operation is done.
    " Driven by the g:pyinvim_gotolinewhendone setting.
    if exists('g:pyinvim_gotolinewhendone')
        if g:pyinvim_gotolinewhendone == ''
            " do nothing.
        elseif g:pyinvim_gotolinewhendone == 'start'
            execute 'normal! ' . a:lineStart2 . 'gg'
        elseif g:pyinvim_gotolinewhendone == 'finish'
            execute 'normal! ' . a:lineFinish2 . 'gg'
        else
            execute 'normal! ' . g:pyinvim_gotolinewhendone . 'gg'
        endif
    endif
endfunction


function! pyin#ExecuteAndAppendPython(lineStart, lineFinish)
    " Execute the selection with the Python interpreter,
    " and append the output to the text editing area.

    let l1 = a:lineStart
    let l2 = a:lineFinish
    let whole_buffer_used = 0
    let last_linenr = line("$")
    let cur_linenr = line(".")
    if l1 == l2
        let whole_buffer_used = 1
        " if no line is selected or 1 line is selected,
        " behave as all of the buffer is selected.
        let l1 = 1
        let l2 = last_linenr
    endif
    let codeAsList = getline(l1, l2)

    let outputAsList = pyin#RunPythonCode(codeAsList)

    if whole_buffer_used == 1
        call append(last_linenr, outputAsList)
        " cursor, [buffer, linenr, colnr, off]
        call setpos(".", [0, last_linenr, 1, 0])
    else
        call append(a:lineFinish, outputAsList)
        let lineStart2 = a:lineStart
        " the last line of the final state when the operation is done.
        let lineFinish2 = a:lineStart + len(codeAsList) + len(outputAsList)
        call s:GotoLine(lineStart2, lineFinish2)
    endif
endfunction

command! -range PivExecuteAndAppend : call pyin#ExecuteAndAppendPython(<f-line1>,<f-line2>)



function! pyin#ExecuteAndReplacePython(lineStart, lineFinish)
    " Execute the selection with the Python interpreter,
    " and replace the selection with the output of the code.

    " TODO: 4 make this one like above

    let l1 = a:lineStart
    let l2 = a:lineFinish
    if a:lineStart == a:lineFinish
        " if no line is selected or 1 line is selected,
        " behave as all of the buffer is selected.
        let l1 = 1
        let l2 = line("$")
    endif
    let codeAsList = getline(l1, l2)
    " cursorpos, [buffer, linenr, colnr, off]"

    let outputAsList = pyin#RunPythonCode(codeAsList)
    " Decho outputAsList

    " We are doing a replace, so delete the previous code lines.
    let deletionCommand = a:lineStart . ',' . a:lineFinish . 'd'
    " Decho deletionCommand
    execute deletionCommand

    call append(a:lineStart - 1, outputAsList)

    let lineStart2 = a:lineStart
    " the last line of the final state when the operation is done.
    let lineFinish2 = a:lineStart + len(outputAsList)
    call s:GotoLine(lineStart2, lineFinish2)
endfunction

command! -range PivExecuteAndReplace : call pyin#ExecuteAndReplacePython(<f-line1>,<f-line2>)



function! pyin#MakePile()
    " TODO: 5 locate makepile.py first.
    " is it in the file's folder or current folder?
    let cmd = '!python makepile.py'
    exec cmd
endfunction

" command! -nargs=0 PivMakePile : call pyin#MakePile()
" command! -nargs=0 MakePile : call pyin#MakePile()



" TODO: 7 add Spyonde support.
" function! pyin#Spyonde()
"     let fullFileName = shellescape(expand("%:p"))
"     let cmd = '!' . s:Strip(g:pyinvim_cmd_spyonde) . ' ' . fullFileName
"     exec cmd
" endfunction
"
" command! -nargs=0 PivSpyonde : call pyin#Spyonde()



function! pyin#PyRunBuffer()
    let fullFileName = shellescape(expand("%:p"))
    let cmd = '!' . s:Strip(g:pyinvim_interpreter) . ' ' . fullFileName
    exec cmd
endfunction

command! -nargs=0 PivRunBuffer : call pyin#PyRunBuffer()



function! pyin#Pylint()
    let fullFileName = shellescape(expand("%:p"))
    let cmd = '!' . s:Strip(g:pyinvim_cmd_pylint) . ' ' . fullFileName
    exec cmd
endfunction

command! -nargs=0 PivPylint : call pyin#Pylint()



function! pyin#Pep8()
    let fullFileName = shellescape(expand("%:p"))
    let cmd = '!' . s:Strip(g:pyinvim_cmd_pep8) . ' ' . fullFileName
    exec cmd
endfunction

command! -nargs=0 PivPep8 : call pyin#Pep8()



function! pyin#AutoPep8()
    write  " save current buffer.
    let fullFileName = shellescape(expand("%:p"))
    let cmd = '!' . s:Strip(g:pyinvim_cmd_autopep8) . ' -i ' . fullFileName
    exec cmd
    edit  " reload buffer.
endfunction

command! -nargs=0 PivAutoPep8 : call pyin#AutoPep8()



function! pyin#Vulture()
    let fullFileName = shellescape(expand("%:p"))
    let cmd = '!' . s:Strip(g:pyinvim_cmd_vulture) . ' ' . fullFileName
    exec cmd
endfunction

command! -nargs=0 PivVulture : call pyin#Vulture()



function! pyin#Redir(cmd)
  " redirect the output of a Vim or external command into a scratch buffer
  " https://vi.stackexchange.com/a/16607
  if a:cmd =~ '^!'
    execute "let output = system('" . substitute(a:cmd, '^!', '', '') . "')"
  else
    redir => output
    execute a:cmd
    redir END
  endif
  tabnew
  setlocal nobuflisted buftype=nofile bufhidden=wipe noswapfile
  call setline(1, split(output, "\n"))
  put! = a:cmd
  put = '----'
endfunction

" TODO: 6 Add 'Piv' to Redir command.
" TODO: 6 do we need a command for Redir?
command! -nargs=1 Redir silent call Redir(<f-args>)



function! pyin#PyDoc()
    let token = expand("<cword>")
    " TODO: 4 if empty, call PyDocInput
    let cmd = '!' . s:Strip(g:pyinvim_cmd_pydoc) . ' ' . token
    " call system(cmd)
    call pyin#Redir(cmd)
endfunction

command! -nargs=0 PivDoc : call pyin#PyDoc()



function! pyin#PyDocInput()
    " https://stackoverflow.com/a/24156676
    let token = input(">>>")
    let cmd = '!' . s:Strip(g:pyinvim_cmd_pydoc) . ' ' . token
    " call system(cmd)
    call pyin#Redir(cmd)
endfunction

command! -nargs=0 PivDocInput : call pyin#PyDocInput()

