"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Configuration
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let s:console_name = 'term://.//console'
let s:layout = {'position': 'bottom', 'height': 0.3}

" filetype: [rpl-shell-command, paste-pre-command, paste-end-command]
let s:repls = {
    \ 'python': ["ipython\n", "%cpaste -q\n", "--\n"],
    \ 'sh': ["shell\n", "", ""],
    \ }
let s:repl = []

" cover default config
if exists("g:console_name")
    let s:console_name = g:console_name
endif

if exists("g:layout")
    let s:layout = g:layout
endif

if exists("g:repls")
    let s:repls = extend(s:repls, g:repls)
endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Terminal Console
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! s:PasteInTerm(text)
    if len(a:text) >? 0
        let @9 = a:text."\n"
        normal! G"9p
        sleep 50ms
    endif
endfunction

function! s:NewConsole()
    " get REPL command
    if exists("&filetype")
        let l:filetype = substitute(&filetype, "[.]", "_", "g")
        let s:repl = get(s:repls, l:filetype, -1)
    endif

    " create new term-buffer
    execute 'terminal'
    execute 'file '.s:console_name
    setlocal hidden

    " start REPL
    if len(s:repl) ==? 3
        call s:PasteInTerm(s:repl[0]."\n")
        sleep 1  " wait for ipython start
    endif
endfunction

function! console#ShowConsole()
    let l:console_id = bufwinnr(s:console_name)
    if l:console_id >? 0
        " if window exist, jump to the window
        execute l:console_id.'wincmd w'
    else
        let l:width  = get(s:layout, 'width', -1) * winwidth('%')
        let l:height = get(s:layout, 'height', -1) * winheight('%')

        " if window not exist, create window
        execute 'split'
        let l:layouts = {'right':'L', 'bottom':'J', 'left':'H', 'top':'K'}
        execute "wincmd ".get(l:layouts, get(s:layout, 'position', 'bottom'), 'J')

        " resize console window
        if l:width >? 0
            execute string(l:width).'wincmd |'
        endif
        if l:height >? 0
            execute string(l:height).'wincmd _'
        endif

        if bufexists(s:console_name)
            " if buffer exist, show in the window
            execute 'buffer '.s:console_name
        else
            " if buffer not exist, create new term-buffer
            call s:NewConsole()
        endif
    endif
endfunction

function! console#ToggleConsole()
    let l:console_id = bufwinnr(s:console_name)
    if l:console_id >? 0
        " if window exist, jump to the window
        execute l:console_id.'wincmd w'
        wincmd q
        stopinsert
    else
        call console#ShowConsole()
    endif
endfunction


function! console#Send(text)
    call console#ShowConsole()

    if len(s:repl) ==? 3 && len(a:text) >? 0
        call s:PasteInTerm(s:repl[1])
        call s:PasteInTerm(a:text.s:repl[2])
    else
        call s:PasteInTerm(a:text)
    endif

    wincmd p
    stopinsert
endfunction
