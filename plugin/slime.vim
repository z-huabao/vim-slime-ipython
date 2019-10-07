if exists('g:loaded_slime_ipython') || &cp || v:version < 700
    finish
endif
let g:loaded_slime_ipython = 1

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Setup key bindings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
noremap <unique> <script> <silent> <Plug>PrevCell :<c-u>call cell#PrevCell()<cr>
noremap <unique> <script> <silent> <Plug>NextCell :<c-u>call cell#NextCell()<cr>
noremap <unique> <script> <silent> <Plug>MoveCellUp :<c-u>call cell#MoveCellUp()<cr>
noremap <unique> <script> <silent> <Plug>MoveCellDown :<c-u>call cell#MoveCellDown()<cr>
noremap <unique> <script> <silent> <Plug>CutCurrentCell :<c-u>call cell#CutCurrentCell()<cr>
noremap <unique> <script> <silent> <Plug>CopyCurrentCell :<c-u>let @" = cell#GetCurrentCell(0)<cr>

noremap <unique> <script> <silent> <Plug>ShowConsole :<c-u>call console#ShowConsole()<cr>
noremap <unique> <script> <silent> <Plug>ToggleConsole :<c-u>call console#ToggleConsole()<cr>
noremap <unique> <script> <silent> <Plug>SendAll :<c-u>call console#Send(cell#GetAll())<cr>
noremap <unique> <script> <silent> <Plug>SendCurrentCell :<c-u>call console#Send(cell#GetCurrentCell(0))<cr>
noremap <unique> <script> <silent> <Plug>SendCurrentCellNext :<c-u>call console#Send(cell#GetCurrentCell(1))<cr>

if !exists("g:slime_ipython_no_mappings") || !g:slime_ipython_no_mappings
  "if !hasmapto('<Plug>SlimeRegionSend', 'x')
    "xmap <c-c><c-c> <Plug>SlimeRegionSend
  "endif
    nmap <A-x> <Plug>CutCurrentCell
    nmap <A-c> <Plug>CopyCurrentCell
    nmap <A-up> <Plug>PrevCell
    nmap <A-down> <Plug>NextCell
    nmap <leader>w <Plug>ToggleConsole
    nmap <F5> <Plug>SendAll
    nmap <A-Enter> <Plug>SendCurrentCellNext
endif

