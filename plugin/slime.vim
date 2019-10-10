if exists('g:loaded_slime_ipython') || &cp || v:version < 700
    finish
endif
let g:loaded_slime_ipython = 1

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Setup key bindings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
command! PrevCell call cell#PrevCell()
command! NextCell call cell#NextCell()
command! MoveCellUp call cell#MoveCellUp()
command! MoveCellDown call cell#MoveCellDown()
command! CutCurrentCell call cell#CutCurrentCell()
command! CopyCurrentCell let @" = cell#GetCurrentCell(0) | echo 'copy the cell'

command! ShowConsole call console#ShowConsole()
command! ToggleConsole call console#ToggleConsole()
command! SendAll call console#Send(cell#GetAll())
command! SendCurrentCell call console#Send(cell#GetCurrentCell(0))
command! SendCurrentCellNext call console#Send(cell#GetCurrentCell(1))


if !exists("g:slime_ipython_no_submode") || !g:slime_ipython_no_submode
    call submode#AddMode('cell-mode',
        \{
        \   'mode': 'normal',
        \   'scope': 'buffer',
        \   'enter_keys': [],
        \   'leave_keys': ['<CR>', 'q', 'i', 'a'],
        \   'enter_func': 'cell#HighLightSpace',
        \   'leave_func': 'cell#HighLightSpace',
        \   'maps': {
        \       '<M-CR>': ':SendCurrentCellNext<CR>',
        \       'j': ':NextCell<CR>',
        \       'k': ':PrevCell<CR>',
        \       'J': ':MoveCellDown<CR>',
        \       'K': ':MoveCellUp<CR>',
        \       'dd': ':CutCurrentCell<CR>',
        \       'yy': ':CopyCurrentCell<CR>',
        \   }
        \}
        \)
endif

if !exists("g:slime_ipython_no_highlight") || !g:slime_ipython_no_highlight
    syntax match CellSpace /^$/
    highlight CellSpace guibg=gray30 ctermbg=20
    sign define cell_space linehl=CellSpace
    augroup AutoHighLightCellSpace
        autocmd TextChanged * call cell#HighLightSpace()
    augroup endgroup
endif

if !exists("g:slime_ipython_no_mappings") || !g:slime_ipython_no_mappings
    nnoremap <Leader>t :ToggleConsole<CR>

    if !exists("g:slime_ipython_no_submode") || !g:slime_ipython_no_submode
        call submode#MapEnterKeys('cell-mode', ['<M-CR>', '<Leader><Esc>'])
        augroup AutoLeaveCellMode
            autocmd InsertEnter * call submode#LeaveMode('cell-mode', 'i')
        augroup endgroup
    endif
endif

