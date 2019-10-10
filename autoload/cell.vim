"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Cell Manager
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! s:GetCellStart(i)
    let flag = 0
    let i = a:i
    while i >? 0
        if flag && getline(i) !~ '\S'  " none or only space
            return i + 1
        elseif getline(i)[0] =~ '\S'
            let flag = 1
        endif
        let i -= 1
    endwhile
    return 1
endfunction

function! s:GetCellEnd(i)
    let flag = 0
    let i = a:i
    let end = i
    while i <=? line('$')
        if flag && getline(i)[0] =~ '\S'
            return [end, i]
        elseif getline(i) !~ '\S'  " none or only space
            let flag = 1
        else
            let end = i
        endif
        let i += 1
    endwhile
    return [i, i]
endfunction

" cell methods
function! cell#GetCurrentCell(...)
    let start = s:GetCellStart(line('.'))
    let end = s:GetCellEnd(line('.'))
    if a:0 && a:1  " auto jump next cell
        execute "normal! ".end[1]."gg"
    endif
    return join(getline(start, end[0]), "\n")."\n"
endfunction

function! cell#GetAll()
    return join(getline(0, line('$')), "\n") + "\n"
endfunction

function! cell#CutCurrentCell()
    let start = s:GetCellStart(line('.'))
    let end = s:GetCellEnd(line('.'))
    execute "normal! ".start."gg"
    execute "normal! ".(end[1] - start)."dd"
endfunction

function! cell#PrevCell()
    let start = s:GetCellStart(line('.')) - 1
    execute "normal! ".start."gg"
    let start = s:GetCellStart(start)
    execute "normal! ".start."gg"
endfunction

function! cell#NextCell()
    let end = s:GetCellEnd(line('.'))
    execute "normal! ".end[1]."gg"
endfunction

function! cell#MoveCellUp()
    call cell#CutCurrentCell()
    call cell#PrevCell()
    normal! P
endfunction

function! cell#MoveCellDown()
    call cell#CutCurrentCell()
    call cell#NextCell()
    normal! P
endfunction


" highlight cells
function! s:SignLine(line)
    if !exists('b:cell_space_signs')
        let b:cell_space_signs = []
    endif
    call add(b:cell_space_signs, a:line)
    " highlight by sign
    execute 'sign place '.a:line.' name=cell_space line='.a:line.' buffer='.bufnr('%')
endfunction

function! s:ClearSign()
    if exists('b:cell_space_signs') && len(b:cell_space_signs)
        let file = bufnr('%')
        for i in b:cell_space_signs
            execute 'sign unplace '.i.' buffer='.file
        endfor
    endif
    let b:cell_space_signs = []
endfunction

function! cell#ReadSigns() abort
    redir => l:output
        silent execute 'sign place buffer='.bufnr('%')
    redir end
    return l:output
endfunction

function! cell#HighLightSpace()
    if exists('b:submode') && b:submode ==# 'cell-mode'
        " if nlines no change, return
        let lines = line('$')
        if exists('b:last_lines') && b:last_lines == lines
            return
        endif
        let b:last_lines = lines

        " clear old signs
        call s:ClearSign()

        " not show signcolumn default
        if cell#ReadSigns() !~ 'line='
            set signcolumn=no
        endif
        set nocursorline

        " highlight cell space
        let [a, b] = [1, 1]
        while b < lines
            let [a, b] = s:GetCellEnd(b)
            if a <? b
                for i in range(a+1, b-1)
                    call s:SignLine(i)
                endfor
            endif
        endwhile

        " check the first and last line
        for i in [1, lines]
            if getline(i) !~ '\S'  " none or only space
                call s:SignLine(i)
            endif
        endfor
    else
        " clear signs
        call s:ClearSign()
        set signcolumn=auto
        set cursorline
        let b:last_lines = 0
    endif
endfunction

