set tabstop=4     " Tab characters = 4 spaces when displayed
set shiftwidth=2  " Use 2 spaces for each insertion of (auto)indent
set softtabstop=2 " Tabs 'count for' 2 spaces when editing (fake tabs)
set expandtab     " <tab> -> spaces in insert mode
set autoindent    " always set autoindenting on
set smarttab      " Smart tabbing!
set shiftround    " < and > will hit indent levels instead of +-4 always
set list listchars=tab:»·,trail:·
set hlsearch
set incsearch
set number
set wrap
set linebreak
set nolist
set mouse=a
noremap  <buffer> <silent> k gk
noremap  <buffer> <silent> j gj
syntax on
filetype plugin on

" tab settings for Makefiles
autocmd BufEnter ?akefile* set noet ts=8 sts=8 sw=8
set paste
nmap \nt :NERDTree<CR>
nmap \nc :NERDTreeClose<CR>
nmap \jl :JSLintToggle<CR>
nmap \ju :JSLintUpdate<CR>
nmap \jo :let g:JSLintHighlightErrorLine = 0<CR>:JSLintUpdate<CR>
nmap \jn :let g:JSLintHighlightErrorLine = 1<CR>:JSLintUpdate<CR>
