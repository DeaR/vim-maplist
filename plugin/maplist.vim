" Sorted, Collected, Fix to <M-...>.
"
" Maintainer:   DeaR <nayuri@kuonn.mydns.jp>
" Last Change:  21-Apr-2016.
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

if exists('g:loaded_maplist')
  finish
endif
let g:loaded_maplist = 1

let s:save_cpo = &cpo
set cpo&vim

command! -bar -bang MapList
\ call maplist#echo('<bang>')
command! -bar NMapList
\ call maplist#echo('n')
command! -bar OMapList
\ call maplist#echo('o')
command! -bar VMapList
\ call maplist#echo('v')
command! -bar XMapList
\ call maplist#echo('x')
command! -bar SMapList
\ call maplist#echo('s')
command! -bar IMapList
\ call maplist#echo('i')
command! -bar CMapList
\ call maplist#echo('c')
command! -bar LMapList
\ call maplist#echo('l')

let &cpo = s:save_cpo
unlet s:save_cpo
