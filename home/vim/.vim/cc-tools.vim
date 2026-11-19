" Compartido por Vim (~/.vimrc) y Neovim (lua/config/autocmds.lua).
" ---------- Plantilla para archivos .cc, .h y Makefile nuevos ----------
" Marcadores: %FILE% nombre, %DATE% fecha, %GUARD% guard de cabecera
" (p02_euclides.h -> P02_EUCLIDES_H_), %EMAIL% email leído de ~/.vim/email.local
" (fichero local, fuera del repo; si no existe, el marcador se elimina).
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
  let l:email_file = expand('~/.vim/email.local')
  let l:email = filereadable(l:email_file) ? get(readfile(l:email_file), 0, '') : ''
  silent! %s# *%EMAIL%#\=empty(l:email) ? '' : ' ' . l:email#ge
endfunction

augroup code_templates
  autocmd!
  autocmd BufNewFile *.cc call s:ApplyTemplate('header.cc')
  autocmd BufNewFile *.h call s:ApplyTemplate('header.h')
augroup END

" ---------- Sincronizar X.h y X.cc al guardar ----------
" Al guardar X.h añade a X.cc el esqueleto de las funciones declaradas que aún
" no tenga; al guardar X.cc añade a X.h la declaración de las que defina y no
" estén declaradas. Solo toca el otro fichero y solo añade, nunca borra.
" Limitaciones: funciones libres (firma en columna 0 y en una línea) y se
" comparan por nombre. X_main.cc no se toca.
function! s:FuncName(sig) abort
  return matchstr(a:sig, '\%(operator\s*\S\{1,2}\|\h\w*\)\ze\s*(')
endfunction

" Líneas de firma en columna 0: 'decl' acaba en ');' y 'def' en ') {'.
function! s:Signatures(lines, kind) abort
  let l:end = a:kind ==# 'decl' ? ';' : '{'
  let l:sigs = []
  for l:line in a:lines
    if l:line =~# '^\h' && l:line =~# ')\s*\%(const\)\=\s*' . l:end . '\s*$'
          \ && l:line !~# '::' && s:FuncName(l:line) !~# '^\%(main\)\=$'
      call add(l:sigs, l:line)
    endif
  endfor
  return l:sigs
endfunction

" ¿Hay en lines una firma en columna 0 con ese nombre? (kind: 'decl' o 'def')
function! s:Has(lines, name, kind) abort
  let l:body = a:kind ==# 'def' ? '[^;]*' : '.*'
  let l:pat = '^\h' . l:body . '\<' . escape(a:name, '\.*$^~[]') . '\s*('
  return !empty(filter(copy(a:lines), 'v:val =~# l:pat'))
endfunction

function! s:SyncPair() abort
  let l:base = expand('%:p:r')
  let l:is_header = expand('%:e') ==# 'h'
  if !l:is_header && l:base =~# '_main$'
    return
  endif
  let l:other = l:base . (l:is_header ? '.cc' : '.h')
  if !filereadable(l:other)
    return
  endif
  let l:bufs = filter(getbufinfo(), 'v:val.name ==# l:other')
  if !empty(l:bufs) && l:bufs[0].changed
    echo 'Sync: ' . fnamemodify(l:other, ':t') . ' tiene cambios sin guardar, no se toca'
    return
  endif

  let l:mine = getline(1, '$')
  let l:theirs = readfile(l:other)
  let l:kind = l:is_header ? 'decl' : 'def'
  let l:target = l:is_header ? 'def' : 'decl'
  let l:missing = filter(s:Signatures(l:mine, l:kind),
        \ '!s:Has(l:theirs, s:FuncName(v:val), l:target)')
  if empty(l:missing)
    return
  endif

  if l:is_header
    " Esqueleto en el .cc, sin ';' ni valores por defecto de los parámetros.
    for l:sig in l:missing
      let l:open = stridx(l:sig, '(')
      let l:head = strpart(l:sig, 0, l:open)
      let l:tail = substitute(strpart(l:sig, l:open), '\s*=\s*[^,)]\+', '', 'g')
      let l:tail = substitute(l:tail, '\s*;\s*$', '', '')
      call extend(l:theirs, ['', l:head . l:tail . ' {', '  // TODO', '}'])
    endfor
  else
    " Declaración en el .h, justo antes del último #endif.
    let l:endif = match(reverse(copy(l:theirs)), '^#endif')
    let l:endif = l:endif < 0 ? len(l:theirs) : len(l:theirs) - 1 - l:endif
    let l:head = l:endif > 0 ? l:theirs[: l:endif - 1] : []
    while !empty(l:head) && l:head[-1] ==# ''
      call remove(l:head, -1)
    endwhile
    for l:sig in l:missing
      call extend(l:head, ['', substitute(l:sig, '\s*{\s*$', ';', '')])
    endfor
    let l:theirs = l:head + [''] + l:theirs[l:endif :]
  endif

  call writefile(l:theirs, l:other)
  if !empty(l:bufs)
    call setbufvar(l:bufs[0].bufnr, '&autoread', 1)
    execute 'silent checktime' l:bufs[0].bufnr
  endif
  echo 'Sync: +' . len(l:missing) . ' en ' . fnamemodify(l:other, ':t')
endfunction

augroup sync_header_source
  autocmd!
  autocmd BufWritePost *.h,*.cc call s:SyncPair()
augroup END

" ---------- Plantilla para archivos Makefile nuevos ----------
autocmd FileType make setlocal noexpandtab
augroup make_template
  autocmd!
  autocmd BufNewFile Makefile,makefile,GNUmakefile,*.mk call s:ApplyTemplate('makefile.template')
augroup END

" ---------- Erratas típicas de Shift (:Q, :W, :Wq, :WQ) ----------
command! -bang Q quit<bang>
command! -bang W write<bang>
command! -bang Wq wq<bang>
command! -bang WQ wq<bang>
