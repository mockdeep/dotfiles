execute pathogen#infect()
set tabstop=2     " Tab characters = 4 spaces when displayed
set shiftwidth=2  " Use 2 spaces for each insertion of (auto)indent
set softtabstop=2 " Tabs 'count for' 2 spaces when editing (fake tabs)
set expandtab     " <tab> -> spaces in insert mode
set smarttab      " Smart tabbing!
set shiftround    " < and > will hit indent levels instead of +-4 always
set hlsearch
set incsearch
set relativenumber
set wrap
set linebreak
set nolist
set showcmd
set colorcolumn=80
set formatprg=par
set wildignore+=*/public/assets/*,*/tmp/*,*.so,*.swp,*.zip

highlight ColorColumn ctermbg=0
noremap  <buffer> <silent> k gk
noremap  <buffer> <silent> j gj
syntax on
filetype plugin indent on
set list listchars=tab:»·,trail:·
au BufNewFile,BufRead Guardfile set filetype=ruby

" tab settings for Makefiles
" autocmd BufEnter ?akefile* set noet ts=8 sts=8 sw=8
autocmd VimEnter * if !argc() | NERDTree | endif
" remove all trailing spaces in file before saving
" probably better to leave this out for now
" autocmd BufWritePre * :%s/\s\+$//e
set paste
map <Leader>o :call RunCurrentLineInTest()<CR>
map <Leader>t :w<cr>:call RunCurrentTest()<CR>
nmap \nt :NERDTree<CR>
nmap \nc :NERDTreeClose<CR>
nmap \jl :JSLintToggle<CR>
nmap \ju :JSLintUpdate<CR>
nmap \jo :let g:JSLintHighlightErrorLine = 0<CR>:JSLintUpdate<CR>
nmap \jn :let g:JSLintHighlightErrorLine = 1<CR>:JSLintUpdate<CR>
nmap \rt :retab<CR>:%s/\s\+$//ge<CR>
let g:ctrlp_max_files=0
set ruler
set autoindent    " always set autoindenting on

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Test-running stuff
" courtesy of Ben Orenstein: https://github.com/r00k/dotfiles/blob/master/vimrc
" doesn't work yet...
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! RunCurrentTest()
  let in_test_file = match(expand("%"), '\(.feature\|_spec.rb\|_test.rb\)$') != -1
  if in_test_file
    call SetTestFile()

    if match(expand('%'), '\.feature$') != -1
      call SetTestRunner("!cucumber")
      exec g:bjo_test_runner g:bjo_test_file
    elseif match(expand('%'), '_spec\.rb$') != -1
      call SetTestRunner("!bin/rspec")
      exec g:bjo_test_runner g:bjo_test_file
    else
      call SetTestRunner("!ruby -Itest")
      exec g:bjo_test_runner g:bjo_test_file
    endif
  else
    exec g:bjo_test_runner g:bjo_test_file
  endif
endfunction

function! SetTestRunner(runner)
  let g:bjo_test_runner=a:runner
endfunction

function! RunCurrentLineInTest()
  let in_test_file = match(expand("%"), '\(.feature\|_spec.rb\|_test.rb\)$') != -1
  if in_test_file
    call SetTestFileWithLine()
  end

  exec "!bin/rspec" g:bjo_test_file . ":" . g:bjo_test_file_line
endfunction

function! SetTestFile()
  let g:bjo_test_file=@%
endfunction

function! SetTestFileWithLine()
  let g:bjo_test_file=@%
  let g:bjo_test_file_line=line(".")
endfunction
