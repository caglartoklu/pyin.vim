" -*- vim -*-
" FILE: pyin.vim
" PLUGINTYPE: plugin
" DESCRIPTION: Executes Python code in Vim buffers and insert its output.
" HOMEPAGE: https://github.com/caglartoklu/pyin.vim
" LICENSE: https://github.com/caglartoklu/pyin.vim/blob/master/LICENSE
" AUTHOR: caglartoklu


if exists('g:loaded_python_inline') || &cp
    " If it already loaded, do not load it again.
    finish
endif


" mark that plugin loaded
let g:loaded_python_inline = 1


" commands exposed
command! -range PyinvimExecuteAndAppend :
    \call s:ExecuteAndAppendPython(<f-line1>,<f-line2>)
command! -range PyinvimExecuteAndReplace :
    \call s:ExecuteAndReplacePython(<f-line1>,<f-line2>)


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

endfunction


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


function! s:Strip(input_string)
    " Strips (or trims) leading and trailing whitespace.
    " http://stackoverflow.com/a/4479072
    return substitute(a:input_string, '^\s*\(.\{-}\)\s*$', '\1', '')
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
    let oneLine2 = s:Strip(a:oneLine) . "\r"
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
    let outputAsList = split(output, "\n")

    if g:pyinvim_delete_temp_files == 1
        " Remove the temp source file.
        call delete(tempSourceFileName)
    endif

    return outputAsList
endfunction


function! s:ExecuteAndAppendPython(lineStart, lineFinish)
    " Execute the selection with the Python interpreter,
    " and append the output to the text editing area.
    let codeAsList = getline(a:lineStart, a:lineFinish)
    let outputAsList = pyin#RunPythonCode(codeAsList)
    call append(a:lineFinish, outputAsList)
    " Decho outputAsList
endfunction


function! s:ExecuteAndReplacePython(lineStart, lineFinish)
    " Execute the selection with the Python interpreter,
    " and replace the selection with the output of the code.
    let codeAsList = getline(a:lineStart, a:lineFinish)
    let outputAsList = pyin#RunPythonCode(codeAsList)
    " Decho outputAsList

    " We are doing a replace, so delete the previous code lines.
    let deletionCommand = a:lineStart . ',' . a:lineFinish . 'd'
    " Decho deletionCommand
    execute deletionCommand

    call append(a:lineStart - 1, outputAsList)
endfunction


" Define the settings once.
call s:SetPyinvimSettings()
