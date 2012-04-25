set tabstop=4     " Tab characters = 4 spaces when displayed
set shiftwidth=2  " Use 2 spaces for each insertion of (auto)indent
set softtabstop=2 " Tabs 'count for' 2 spaces when editing (fake tabs)
set expandtab     " <tab> -> spaces in insert mode
set autoindent    " always set autoindenting on
set smarttab      " Smart tabbing!
set shiftround    " < and > will hit indent levels instead of +-4 always
set hlsearch
set incsearch
set number
set wrap
set linebreak
set nolist
set iskeyword-=_
noremap  <buffer> <silent> k gk
noremap  <buffer> <silent> j gj
syntax on
filetype plugin on
set list listchars=tab:»·,trail:·

" tab settings for Makefiles
" autocmd BufEnter ?akefile* set noet ts=8 sts=8 sw=8
autocmd VimEnter * if !argc() | NERDTree | endif
" remove all trailing spaces in file before saving
" probably better to leave this out for now
" autocmd BufWritePre * :%s/\s\+$//e
set paste
nmap \nt :NERDTree<CR>
nmap \nc :NERDTreeClose<CR>
nmap \jl :JSLintToggle<CR>
nmap \ju :JSLintUpdate<CR>
nmap \jo :let g:JSLintHighlightErrorLine = 0<CR>:JSLintUpdate<CR>
nmap \jn :let g:JSLintHighlightErrorLine = 1<CR>:JSLintUpdate<CR>
set ruler
