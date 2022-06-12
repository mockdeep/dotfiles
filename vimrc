execute pathogen#infect()
set tabstop=2           " Tab characters = 4 spaces when displayed
set shiftwidth=2        " Use 2 spaces for each insertion of (auto)indent
set softtabstop=2       " Tabs 'count for' 2 spaces when editing (fake tabs)
set expandtab           " <tab> -> spaces in insert mode
set smarttab            " Smart tabbing!
set shiftround          " < and > will hit indent levels instead of +-4 always
set hlsearch
set incsearch
set number
set wrap
set linebreak
set nolist
set nojoinspaces
set showcmd             " show command in bottom bar
set cursorline          " highlight current line
set lazyredraw          " redraw only when we need to
set colorcolumn=80
set wildignore+=*/public/assets/*,*/tmp/*,*.so,*.swp,*.zip,*/coverage/*,*/node_modules/*,*/deps/*,*/public/packs*
set foldmethod=syntax
set nofoldenable
set fdo-=search
set scrolloff=5
set autoread
set history=1000
set shortmess-=S        " show search count

highlight ColorColumn ctermbg=0
noremap  <buffer> <silent> k gk
noremap  <buffer> <silent> j gj
syntax on
filetype plugin indent on
set list listchars=tab:»·,trail:·
au BufNewFile,BufRead Guardfile,Vagrantfile set filetype=ruby
au BufNewFile,BufRead *.tsx set filetype=typescript

" tab settings for Makefiles
" autocmd BufEnter ?akefile* set noet ts=8 sts=8 sw=8
autocmd VimEnter * if !argc() | NERDTree | endif
" remove all trailing spaces in file before saving
" probably better to leave this out for now
" autocmd BufWritePre * :%s/\s\+$//e
nmap \nt :NERDTree<CR>
nmap \nc :NERDTreeClose<CR>
nmap \jl :JSLintToggle<CR>
nmap \ju :JSLintUpdate<CR>
nmap \jo :let g:JSLintHighlightErrorLine = 0<CR>:JSLintUpdate<CR>
nmap \jn :let g:JSLintHighlightErrorLine = 1<CR>:JSLintUpdate<CR>
nmap \rt :retab<CR>:%s/\s\+$//ge<CR>
let g:ctrlp_max_files=0
let g:ctrlp_show_hidden=1
let g:javascript_plugin_flow = 1
let g:jsx_ext_required = 0

set ruler
set autoindent    " always set autoindenting on

" puts the caller
nnoremap <leader>wtf oputs "#" * 90<c-m>puts caller<c-m>puts "#" * 90<esc>
noremap <C-y> "+y
