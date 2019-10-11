"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Configuration
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let s:console_name = 'term://.//console'
let s:layout = {'position': 'bottom', 'height': 0.3}

" filetype: [rpl-shell-command, paste-pre-command, paste-end-command]
let s:repls = {
    \ 'python': ["ipython3\n", "%cpaste -q\n", "--\n"],
    \ 'sh': ["shell\n", "", ""],
    \ }
let s:repl = []

" cover default config
if exists("g:slime_ipython_console_name")
    let s:console_name = g:slime_ipython_console_name
endif

if exists("g:slime_ipython_console_layout")
    let s:layout = g:slime_ipython_console_layout
endif

if exists("g:slime_ipython_repls")
    let s:repls = extend(s:repls, g:slime_ipython_repls)
endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Terminal Console
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! s:PasteInVimTerm(text)
    if len(a:text) >? 0
        let nr = bufnr('%')
        if a:text =~ '%cpaste'
            call term_sendkeys(nr, a:text."\n")
            call term_wait(nr)
        else
            for l in split(a:text, '\n\zs')
                call term_sendkeys(nr, substitute(l, '\n', "\r", ''))
                call term_wait(nr)
            endfor
        endif
        sleep 50ms
        startinsert
    endif
endfunction

function! s:PasteInNvimTerm(text)
    if len(a:text) >? 0
        let @9 = a:text."\n"
        normal! G"9p
        sleep 50ms
    endif
endfunction

let s:PasteInTerm = has('nvim') ? function('s:PasteInNvimTerm')
            \: function('s:PasteInVimTerm')

let s:sleep_time = (has('win32')||has('win16')) ? 2 : 1

function! s:NewConsole()
    " get REPL command
    if exists("&filetype")
        let filetype = substitute(&filetype, "[.]", "_", "g")
        let s:repl = get(s:repls, filetype, -1)
    endif

    " create new term-buffer
    execute 'terminal'
    execute 'file '.s:console_name
    setlocal hidden

    " start REPL
    if len(s:repl) ==? 3
        call s:PasteInTerm(s:repl[0])
        " wait for ipython start
        execute 'sleep '.s:sleep_time
    endif
endfunction

function! console#ShowConsole()
    let console_id = bufwinnr(s:console_name)
    if console_id >? 0
        " if window exist, jump to the window
        execute console_id.'wincmd w'
    else
        let width  = get(s:layout, 'width', -1) * winwidth('%')
        let height = get(s:layout, 'height', -1) * winheight('%')

        " if window not exist, create window
        if has('nvim') || bufexists(s:console_name)
            execute 'split'
        endif

        if bufexists(s:console_name)
            " if buffer exist, show in the window
            execute 'buffer '.s:console_name
        else
            " if buffer not exist, create new term-buffer
            call s:NewConsole()
        endif

        " set window position
        let layouts = {'right':'L', 'bottom':'J', 'left':'H', 'top':'K'}
        execute "wincmd ".get(layouts, get(s:layout, 'position', 'bottom'), 'J')

        " resize console window
        if width >? 0
            execute string(width).'wincmd |'
        endif
        if height >? 0
            execute string(height).'wincmd _'
        endif
    endif
endfunction

function! console#ToggleConsole()
    let console_id = bufwinnr(s:console_name)
    if console_id >? 0
        " if window exist, jump to the window
        execute console_id.'wincmd w'
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
