" Port sencillo de cyberdream.nvim (scottmckendry) a Vim, solo la variante oscura.
highlight clear
if exists('syntax_on')
  syntax reset
endif
set background=dark
let g:colors_name = 'cyberdream'

let s:p = {
      \ 'bg': '#16181a', 'bgalt': '#1e2124', 'bgh': '#3c4048', 'grey': '#7b8496',
      \ 'fg': '#ffffff', 'blue': '#5ea1ff', 'green': '#5eff6c', 'cyan': '#5ef1ff',
      \ 'red': '#ff6e5e', 'yellow': '#f1ff5e', 'magenta': '#ff5ef1', 'pink': '#ff5ea0',
      \ 'orange': '#ffbd5e', 'purple': '#bd5eff'}

function! s:h(group, fg, bg, attr) abort
  let l:fg = a:fg ==# 'NONE' ? 'NONE' : s:p[a:fg]
  let l:bg = a:bg ==# 'NONE' ? 'NONE' : s:p[a:bg]
  exe 'highlight ' . a:group . ' guifg=' . l:fg . ' guibg=' . l:bg
        \ . ' gui=' . a:attr . ' cterm=' . a:attr
endfunction

" Interfaz (fondo NONE: usa el del terminal)
call s:h('Normal', 'fg', 'NONE', 'NONE')
call s:h('NonText', 'bgh', 'NONE', 'NONE')
call s:h('EndOfBuffer', 'bg', 'NONE', 'NONE')
call s:h('LineNr', 'bgh', 'NONE', 'NONE')
call s:h('CursorLineNr', 'grey', 'NONE', 'bold')
call s:h('CursorLine', 'NONE', 'bgalt', 'NONE')
call s:h('SignColumn', 'NONE', 'NONE', 'NONE')
call s:h('Visual', 'NONE', 'bgh', 'NONE')
call s:h('Search', 'bg', 'yellow', 'NONE')
call s:h('IncSearch', 'bg', 'orange', 'NONE')
call s:h('MatchParen', 'pink', 'NONE', 'bold')
call s:h('StatusLine', 'fg', 'bgalt', 'NONE')
call s:h('StatusLineNC', 'grey', 'bgalt', 'NONE')
call s:h('VertSplit', 'bgh', 'NONE', 'NONE')
call s:h('Pmenu', 'fg', 'bgalt', 'NONE')
call s:h('PmenuSel', 'bg', 'cyan', 'NONE')
call s:h('Folded', 'grey', 'bgalt', 'NONE')
call s:h('Directory', 'blue', 'NONE', 'NONE')
call s:h('Title', 'blue', 'NONE', 'bold')
call s:h('ErrorMsg', 'red', 'NONE', 'bold')
call s:h('WarningMsg', 'orange', 'NONE', 'NONE')
call s:h('Todo', 'yellow', 'NONE', 'bold')

" Sintaxis
call s:h('Comment', 'grey', 'NONE', 'italic')
call s:h('Constant', 'orange', 'NONE', 'NONE')
call s:h('String', 'green', 'NONE', 'NONE')
call s:h('Character', 'green', 'NONE', 'NONE')
call s:h('Number', 'orange', 'NONE', 'NONE')
call s:h('Boolean', 'orange', 'NONE', 'NONE')
call s:h('Identifier', 'fg', 'NONE', 'NONE')
call s:h('Function', 'blue', 'NONE', 'NONE')
call s:h('Statement', 'magenta', 'NONE', 'NONE')
call s:h('Operator', 'cyan', 'NONE', 'NONE')
call s:h('PreProc', 'pink', 'NONE', 'NONE')
call s:h('Type', 'cyan', 'NONE', 'NONE')
call s:h('Special', 'purple', 'NONE', 'NONE')
call s:h('Delimiter', 'fg', 'NONE', 'NONE')
call s:h('Error', 'red', 'NONE', 'NONE')
