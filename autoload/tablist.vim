let s:save_cpo = &cpo
set cpo&vim

let s:title = '-TAB LIST-'
let s:tabnewMark = '-tabnew-'

function! tablist#Show()
  if s:ShowTablist()  ==# -1
    call s:CreateBuf()
    call s:Refresh()
    call cursor([2, 1])
  else
    call s:Refresh()
  endif
endfunction

function! s:CreateBuf()
  0tabnew
  silent! execute 'file' s:title
  set ft=tablist
  setlocal cursorline
  setlocal nowrap
  nnoremap <buffer> <silent> <nowait> q <Cmd>call <SID>CloseTablist()<CR>
  nnoremap <buffer> <silent> <CR> <Cmd>call <SID>ShowTab()<CR>
  vnoremap <buffer> <silent> <CR> <Cmd>call <SID>ShowTab()<CR>
  nnoremap <buffer> <silent> r <Cmd>call <SID>Refresh()<CR>
  nnoremap <buffer> <silent> d :call <SID>CloseTab(0)<CR>
  vnoremap <buffer> <silent> d :call <SID>CloseTab(0)<CR>
  nnoremap <buffer> <silent> D :call <SID>CloseTab(1)<CR>
  vnoremap <buffer> <silent> D :call <SID>CloseTab(1)<CR>
  nnoremap <buffer> <silent> J :call <SID>MoveRight('n')<CR>
  vnoremap <buffer> <silent> J :call <SID>MoveRight('v')<CR>
  nnoremap <buffer> <silent> K :call <SID>MoveLeft('n')<CR>
  vnoremap <buffer> <silent> K :call <SID>MoveLeft('v')<CR>
  nnoremap <buffer> <silent> o :call <SID>NewTabAfter()<CR>
  nnoremap <buffer> <silent> O :call <SID>NewTabBefore()<CR>
  syntax match MoreMsg / >.*$/
  execute 'syntax match Title /^' . s:title . '$/'
  execute 'syntax match Delimiter /^' . s:tabnewMark . '$/'
  autocmd BufEnter <buffer> call s:Refresh()
endfunction

function! s:ShowTablist() abort
  for l:i in range(1, tabpagenr('$'))
    for l:b in tabpagebuflist(l:i)
      if fnamemodify(bufname(l:b), ':t') ==# s:title
        execute 'tabnext' l:i
        execute bufwinnr(l:b) . 'wincmd w'
        return 1
      endif
    endfor
  endfor
  return -1
endfunction

function! s:CloseTablist() abort
  call s:ShowTab(tabpagenr('#'))
endfunction

function! s:Refresh() abort
  if s:ShowTablist()  ==# -1
    return
  endif
  let l:cur = getpos('.')
  set noreadonly
  silent %d
  for l:index in range(1, tabpagenr('$'))
    let l:w = tabpagewinnr(l:index)
    let l:b = tabpagebuflist(l:index)[l:w - 1]
    let l:name = bufname(l:b)
    if l:name ==# ''
      let l:name = '[No Name]'
    elseif l:name !=# s:title
      let l:name = fnamemodify(l:name, ':t') . ' > ' . expand('#' . l:b . ':p')
    endif
    call setline(l:index, l:name)
  endfor
  let &modified = 0
  set readonly
  call setpos('.', l:cur)
endfunction

function! s:ShowTab(index = 0) abort
  let l:i = a:index ==# 0 ? line('.') : a:index
  let l:current = tabpagenr()
  let l:len = tabpagenr('$')
  quit!
  if l:current < l:i && tabpagenr('$') < l:len
    let l:i = l:i - 1
  endif
  execute 'tabnext' l:i
endfunction

function! s:CloseTab(force) range abort
  let l:cmd = a:force ? 'quit!' : 'confirm quit'
  execute a:firstline ',' a:lastline 'tabdo' 'for tablist_i in range(1, winnr("$")) |' l:cmd '| endfor'
  silent! unlet tablist_i
  call s:Refresh()
endfunction

function! s:MoveRight(m) range abort
  if a:lastline !=# line('$')
    call s:Move(a:lastline + 1, a:firstline - 1, 1, a:m)
  endif
endfunction

function! s:MoveLeft(m) range abort
  if a:firstline !=# 1
    call s:Move(a:firstline - 1, a:lastline, -1, a:m)
  endif
endfunction

function! s:AddedPos(from, d) abort
  let l:p = getpos(a:from)
  let l:p[1] = l:p[1] + a:d
  return l:p
endfunction

function! s:Move(f, t, d, m) abort
  let l:nc = s:AddedPos('.', a:d)
  let l:vs = s:AddedPos("'<", a:d)
  let l:ve = s:AddedPos("'>", a:d)
  execute 'tabnext' a:f
  execute 'tabmove' a:t
  call s:Refresh()
  call setpos('.', l:nc)
  if a:m == 'v'
    call setpos("'<", l:vs)
    call setpos("'>", l:ve)
    normal! gv
  endif
endfunction

function! s:NewTabAfter() abort
  let l:i = line('.')
  set noreadonly
  execute 'normal! o' . s:tabnewMark . "\<ESC>"
  let &modified = 0
  set readonly
  redraw
  let l:file = input('tabnew ', '' , 'file')
  let l:cmd = l:i ==# tabpagenr('$') ? '$tabnew' : 'tabnew'
  call s:ShowTab(l:i)
  execute l:cmd l:file
endfunction

function! s:NewTabBefore() abort
  let l:i = line('.')
  set noreadonly
  execute 'normal! O' . s:tabnewMark . "\<ESC>"
  let &modified = 0
  set readonly
  redraw
  let l:file = input('tabnew ', '' , 'file')
  let l:cmd = l:i ==# 1 ? '0tabnew' : '-tabnew'
  call s:ShowTab(l:i)
  execute l:cmd l:file
endfunction

let &cpo = s:save_cpo
