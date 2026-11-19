" ---------- Básico ----------
set nocompatible
syntax on
" Dentro de tmux (TERM=tmux-256color) Vim no detecta el fondo oscuro ni el
" truecolor, y cae a colores pensados para fondo claro.
set background=dark
if has('termguicolors')
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
  set termguicolors
endif
colorscheme cyberdream
" Fondo del terminal (negro) en vez del que trae el esquema
for g in ['Normal', 'NonText', 'EndOfBuffer', 'LineNr', 'SignColumn', 'FoldColumn']
  exe 'highlight ' . g . ' guibg=NONE ctermbg=NONE'
endfor
set number
set ruler
set showcmd
set wildmenu
set mouse=a
set scrolloff=5
set backspace=indent,eol,start
set clipboard=unnamedplus
set virtualedit=onemore
set hidden
set updatetime=300
set splitright splitbelow
set laststatus=2
set hlsearch incsearch ignorecase smartcase
let mapleader=" "
nnoremap <leader><space> :nohlsearch<CR>
nnoremap <C-s> :w<CR>
inoremap <C-s> <Esc>:w<CR>a
vnoremap <C-s> <Esc>:w<CR>

" ---------- Indentación (2 espacios, estilo Google) ----------
set expandtab
set tabstop=2
set sw=2

" ---------- Deshacer persistente ----------
if !isdirectory(expand('~/.vim/undo'))
  call mkdir(expand('~/.vim/undo'), 'p')
endif
set undofile
set undodir=~/.vim/undo

" ---------- Swap en una carpeta propia (no ensucia los proyectos) ----------
if !isdirectory(expand('~/.vim/swap'))
  call mkdir(expand('~/.vim/swap'), 'p')
endif
set directory=~/.vim/swap//

" ---------- Recordar la última posición del cursor ----------
autocmd BufReadPost *
     \ if line("'\"") > 0 && line("'\"") <= line("$") |
     \   exe "normal! g`\"" |
     \ endif

" ---------- Plantillas, sync .h/.cc, Makefile y erratas (compartido con Neovim) ----------
if filereadable(expand('~/.vim/cc-tools.vim'))
  source ~/.vim/cc-tools.vim
endif

" ---------- Plugins (vim-plug lo instala install.sh) ----------
if filereadable(expand('~/.vim/autoload/plug.vim'))
  call plug#begin()
    Plug 'jiangmiao/auto-pairs'
    Plug 'itchyny/lightline.vim'
  call plug#end()
endif

" ---------- Barra de estado (lightline) ----------
set noshowmode
let g:lightline = {'colorscheme': 'jellybeans'}

