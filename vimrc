set tabstop=4     " Tab characters = 4 spaces when displayed
set shiftwidth=2  " Use 2 spaces for each insertion of (auto)indent
set softtabstop=2 " Tabs 'count for' 2 spaces when editing (fake tabs)
set expandtab     " <tab> -> spaces in insert mode
set autoindent    " always set autoindenting on
set smarttab      " Smart tabbing!
set shiftround    " < and > will hit indent levels instead of +-4 always
set list listchars=tab:»·,trail:·
syntax on

" tab settings for Makefiles
autocmd BufEnter ?akefile* set noet ts=8 sts=8 sw=8
set paste
