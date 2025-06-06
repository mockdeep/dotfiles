call plug#begin()

Plug 'dense-analysis/ale'
Plug 'github/copilot.vim'
Plug 'jlanzarotta/bufexplorer'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'nvim-lua/plenary.nvim' " for neo-tree
Plug 'MunifTanjim/nui.nvim' " for neo-tree
Plug 'numToStr/Comment.nvim'
Plug 'nvim-tree/nvim-web-devicons' " for neo-tree
Plug 'https://github.com/nvim-neo-tree/neo-tree.nvim'
Plug 's1n7ax/nvim-window-picker'
Plug 'tpope/vim-abolish'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-rhubarb'
Plug 'tpope/vim-surround'

Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build' }
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'nvim-telescope/telescope.nvim'

call plug#end()

nmap <M-Right> :vertical resize +5<CR>
nmap <M-Left> :vertical resize -5<CR>
nmap <M-Down> :resize +5<CR>
nmap <M-Up> :resize -5<CR>

nmap + /\w\+_\w*<CR>
" nmap <C-t> :GFiles<CR>
" nmap <C-p> :Files<CR>
" https://github.com/nvim-telescope/telescope.nvim/wiki/Configuration-Recipes

" disable Github copilot for txt files
autocmd BufRead,BufNewFile *.txt Copilot disable

let g:ale_set_highlights = 0
let g:ale_sign_column_always = 1
" let g:ale_fix_on_save = 1
let g:ale_fixers = {
\  'javascript': ['eslint'],
\  'typescript': ['eslint'],
\  'ruby': ['rubocop'],
\}
nmap <C-p> :Telescope git_files hidden={true}<CR>
nnoremap <silent> <leader>g% :let @+=expand('%')<CR>
nnoremap <leader>gg <cmd>Telescope live_grep<cr>
nnoremap <leader>gga <cmd>Telescope live_grep search_dirs={"app/"}<cr>
nnoremap <leader>ggjs <cmd>Telescope live_grep search_dirs={"app/javascript/","spec/javascript/"}<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>
nmap <leader>re :source ~/.config/nvim/init.vim<CR>
nmap <leader>ec :e ~/.config/nvim/init.vim<CR>
nmap <leader>elc :e ~/.vimrc<CR>
nmap <leader>gb :GBrowse<CR>
vmap <leader>gb :GBrowse<CR>
nmap <leader>nt :Neotree<CR>
nmap <leader>nb :Neotree buffers<CR>
nmap <leader>gs :Neotree git_status<CR>
nmap <leader>nc :Neotree close<CR>
nmap <leader>rt :retab<CR>:%s/\s\+$//ge<CR>
" split elements on the current line across multiple lines:
" :s/[\[{(,]\zs/\r/g<CR> => insert newline after any `[`, `{`, `(` or `,`
" :s/\ze[\]})]/,\r/g<CR> => insert comma and newline before any `]`, `}` or `)`
" mw => mark the current position with 'w'
" gg => go to the top of the file
" =G => indent the whole file
" 'w => go back to the position marked with 'w'
nmap <leader>wr :s/[\[{(,]\zs/\r/g<CR>:s/\ze[\]})]/,\r/g<CR>mwgg=G'w

nmap <leader>pi :PlugInstall<CR>
nmap <leader>c oconsole.log(
vmap <leader>fs !sqlformat --reindent --keywords upper --identifiers lower -<CR>
let g:loaded_perl_provider = 0
set runtimepath^=~/.vim runtimepath+=~/.vim/after
set mouse=
set noswapfile
let &packpath = &runtimepath

lua << EOF
require('Comment').setup()
EOF

source ~/.vimrc
