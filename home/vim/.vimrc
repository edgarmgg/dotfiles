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

" ---------- Plantilla para archivos .cc y .h nuevos ----------
" Marcadores: %FILE% nombre, %DATE% fecha, %GUARD% guard de cabecera
" (p02_euclides.h -> P02_EUCLIDES_H_).
function! s:ApplyTemplate(template) abort
  execute '0r ~/.vim/templates/' . a:template
  if getline('$') ==# ''
    $delete _
  endif
  let l:name = expand('%:t')
  let l:guard = toupper(substitute(l:name, '[^A-Za-z0-9]', '_', 'g')) . '_'
  silent! %s#%FILE%#\=l:name#ge
  silent! %s#%DATE%#\=strftime('%d/%m/%Y')#ge
  silent! %s#%GUARD%#\=l:guard#ge
endfunction

augroup code_templates
  autocmd!
  autocmd BufNewFile *.cc call s:ApplyTemplate('header.cc')
  autocmd BufNewFile *.h call s:ApplyTemplate('header.h')
augroup END

" ---------- Plantilla para archivos Makefile nuevos ----------
autocmd FileType make setlocal noexpandtab
augroup make_template
  autocmd!
  autocmd BufNewFile Makefile,makefile,GNUmakefile,*.mk 0r ~/.vim/templates/makefile.template
augroup END

" ---------- Plugins (vim-plug lo instala install.sh) ----------
if filereadable(expand('~/.vim/autoload/plug.vim'))
  call plug#begin()
    Plug 'jiangmiao/auto-pairs'
  call plug#end()
endif
