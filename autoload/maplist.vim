" Sorted, Collected, Fix to <M-...>.
"
" Maintainer:   DeaR <nayuri@kuonn.mydns.jp>
" Last Change:  22-Apr-2016.
" License:      MIT License {{{
"     Copyright (c) 2016 DeaR <nayuri@kuonn.mydns.jp>
"
"     Permission is hereby granted, free of charge, to any person obtaining a
"     copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to permit
"     persons to whom the Software is furnished to do so, subject to the
"     following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT
"     OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR
"     THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}

let s:save_cpo = &cpo
set cpo&vim

" n  ]]          *@m':call search('^\s*fu\%[nction]\>', "W")<CR>
" ^^^
let g:maplist#mode_length =
  \ get(g:, 'maplist#mode_length', 3)

" n  ]]          *@m':call search('^\s*fu\%[nction]\>', "W")<CR>
"    ^^^^^^^^^^^
let g:maplist#lhs_length =
  \ get(g:, 'maplist#lhs_length', 11)

" n  ]]          *@m':call search('^\s*fu\%[nction]\>', "W")<CR>
"                ^
let g:maplist#remap_length =
  \ get(g:, 'maplist#remap_length', 1)

" n  ]]          *@m':call search('^\s*fu\%[nction]\>', "W")<CR>
"                 ^
let g:maplist#local_length =
  \ get(g:, 'maplist#local_length', 1)

function! s:compare_maparg(i1, i2)
  return
  \ a:i1.noremap == a:i2.noremap &&
  \ a:i1.script  == a:i2.script &&
  \ a:i1.buffer  == a:i2.buffer &&
  \ a:i1.rhs     == a:i2.rhs
endfunction

function! s:extend_mode(i1, i2)
  let i = a:i1 . a:i2
  if i =~ 'x' && i =~ 's'
    let i = substitute(i, 'x', '', '')
    let i = substitute(i, 's', '', '')
    let i .= 'v'
  endif
  if i =~ 'n' && i =~ 'o' && i =~ 'v'
    return ''
  elseif i =~ 'i' && i =~ 'c'
    return ''
  else
    return join([
    \ i =~ 'n' ? 'n' : '',
    \ i =~ 'o' ? 'o' : '',
    \ i =~ 'v' ? 'v' : '',
    \ i =~ 'x' ? 'x' : '',
    \ i =~ 's' ? 's' : '',
    \ i =~ 'i' ? 'i' : '',
    \ i =~ 'c' ? 'c' : '',
    \ i =~ 'l' ? 'l' : ''], '')
  endif
endfunction

function! s:add_map(maps, dict)
  if empty(a:dict)
    return a:maps
  endif

  for m in filter(copy(a:maps), 'v:val.keycord == a:dict.keycord')
    if s:compare_maparg(m, a:dict)
      let a:maps[index(a:maps, m)].mode = s:extend_mode(m.mode, a:dict.mode)
      return a:maps
    endif
  endfor
  return add(a:maps, a:dict)
endfunction

function! s:strtrim(expr)
  return substitute(a:expr, '^\s\+\|\s\+$', '', 'g')
endfunction

function! s:struntrans(expr)
  let expr = a:expr

  " <xxx>
  let s = matchlist(expr, '\(.*\)\(<[^>]\+>\)\(.*\)')
  while !empty(s)
    execute 'let c = "\' . escape(s[2], '\') . '"'
    let expr = s[1] . c . s[3]
    let s = matchlist(expr, '\(.*\)\(<[^>]\+>\)\(.*\)')
  endwhile

  return expr
endfunction

function! s:strtrans(expr)
  let expr = a:expr

  " <M-xxx>
  for i in range(0xa1, 0xfe)
    let expr = substitute(expr, nr2char(i), "<M-" . escape(nr2char(i - 0x80), '\') . ">", 'g')
  endfor

  " <M-C-xxx>
  for i in range(0x81, 0x88) + range(0x8e, 0x9a) + range(0x9d, 0x9f) + [0x8b, 0x8c]
    let expr = substitute(expr, nr2char(i), "<M-C-" . escape(nr2char(i - 0x40), '\') . ">", 'g')
  endfor

  " Others
  let expr = substitute(expr, "\<M-Nul>",     "<M-Nul>",     'g')
  let expr = substitute(expr, "\<M-Tab>",     "<M-Tab>",     'g')
  let expr = substitute(expr, "\<M-NL>",      "<M-NL>",      'g')
  let expr = substitute(expr, "\<M-CR>",      "<M-CR>",      'g')
  " let expr = substitute(expr, "\<M-Esc>",     "<M-Esc>",     'g')
  let expr = substitute(expr, "\<M-\\>",      " <M-\\\\>",   'g')
  " let expr = substitute(expr, "\<M-C-Space>", "<M-C-Space>", 'g')

  return expr
endfunction

function! s:sort_map(i1, i2)
  if a:i1.buffer != a:i2.buffer
    return a:i1.buffer < a:i2.buffer ? 1 : -1
  elseif a:i1.keycord == a:i2.keycord
    for m in ['n', 'o', 'v', 'x', 's', 'i', 'c', 'l']
      if a:i1.mode =~ m
        return -1
      elseif a:i2.mode =~ m
        return 1
      endif
    endfor
    return 0
  else
    return a:i1.keycord > a:i2.keycord ? 1 : -1
  endif
endfunction

function! maplist#get(mode)
  redir => out
  silent execute
  \ (a:mode != '!' ? a:mode : '') .
  \ 'map' .
  \ (a:mode != '!' ? '' : a:mode)
  redir END

  let maps = []
  for line in split(out, '\n')
    let m = matchlist(line, '^\(...\)\(\S\+\)\s\+\([ *&]\)\([ @]\)\(.*\)$')
    call s:add_map(maps, {
    \ 'mode'    : s:strtrim(m[1]),
    \ 'keycord' : s:struntrans(m[2]),
    \ 'lhs'     : s:strtrans(m[2]),
    \ 'noremap' : m[3] != ' ',
    \ 'script'  : m[3] == '&',
    \ 'buffer'  : m[4] != ' ',
    \ 'rhs'     : m[5]})
  endfor
  return sort(maps, 's:sort_map')
endfunction

function! s:echon(msg)
  let msg = a:msg
  let idx = match(msg, '<[^>]\+>')

  while idx >= 0
    if idx > 0
      echon msg[:idx - 1]
    endif

    let end = matchend(msg, '<[^>]\+>')
    echohl SpecialKey
    echon msg[idx:end - 1]
    echohl None

    let msg = msg[end:]
    let idx = match(msg, '<[^>]\+>')
  endwhile

  echon msg
endfunction

function! maplist#echo(mode)
  for line in maplist#get(a:mode)
    echon printf('%-' . g:maplist#mode_length . 's', line.mode)

    call s:echon(line.lhs)
    echon printf('%' . max([0, g:maplist#lhs_length - len(line.lhs)]) . 's', ' ')

    echohl SpecialKey
    echon printf('%-' . g:maplist#remap_length . 's', line.script ? '&' : line.noremap ? '*' : '')
    echohl None

    echon printf('%-' . g:maplist#local_length . 's', line.buffer ? '@' : '')

    call s:echon(line.rhs)
    echo ''
  endfor
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
