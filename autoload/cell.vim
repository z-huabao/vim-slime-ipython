"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Cell Manager
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! s:GetCellStart()
    let l:flag = 0
    let l:i = line('.')
    while l:i >? 0
        if l:flag && getline(l:i) !~ '\S'  " none or only space
            return l:i + 1
        elseif getline(l:i)[0] =~ '\S'
            let l:flag = 1
        endif
        let l:i = l:i - 1
    endwhile
    return 1
endfunction

function! s:GetCellEnd()
    let l:flag = 0
    let l:i = line('.')
    let l:end = l:i
    while l:i <=? line('$')
        if l:flag && getline(l:i)[0] =~ '\S'
            return [l:end, l:i]
        elseif getline(l:i) !~ '\S'  " none or only space
            let l:flag = 1
        else
            let l:end = l:i
        endif
        let l:i = l:i + 1
    endwhile
    return [l:i, l:i]
endfunction

function! cell#GetCurrentCell(...)
    let l:start = s:GetCellStart()
    let l:end = s:GetCellEnd()
    if a:0 && a:1  " auto jump next cell
        execute "normal! ".l:end[1]."gg"
    endif
    return join(getline(l:start, l:end[0]), "\n")."\n"
endfunction

function! cell#GetAll()
    return join(getline(0, line('$')), "\n") + "\n"
endfunction

function! cell#CutCurrentCell()
    let l:start = s:GetCellStart()
    let l:end = s:GetCellEnd()
    execute "normal! ".l:start."gg"
    execute "normal! ".(l:end[1] - l:start)."dd"
endfunction

function! cell#PrevCell()
    let l:start = s:GetCellStart() - 1
    execute "normal! ".l:start."gg"
    let l:start = s:GetCellStart()
    execute "normal! ".l:start."gg"
endfunction

function! cell#NextCell()
    let l:end = s:GetCellEnd()
    execute "normal! ".l:end[1]."gg"
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

