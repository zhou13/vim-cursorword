" =============================================================================
" Filename: plugin/cursorword.vim
" Author: Yichao Zhou
" License: MIT License
" Last Change: 2017/05/26 00:47:31.
" =============================================================================

if exists('g:loaded_cursorword') || v:version < 703
  finish
endif
let g:loaded_cursorword = 1

let s:save_cpo = &cpo
set cpo&vim

highlight default CursorWord term=underline cterm=underline gui=underline

function! s:matchadd(...) abort
  let enable = get(b:, 'cursorword', get(g:, 'cursorword', 1)) && !has('vim_starting')
  if !enable && !get(w:, 'cursorword_match') | return | endif
  let i = (a:0 ? a:1 : mode() ==# 'i' || mode() ==# 'R') && col('.') > 1
  let line = getline('.')
  let linenr = line('.')
  let word = matchstr(line[:(col('.')-i-1)], '\k*$') . matchstr(line[(col('.')-i-1):], '^\k*')[1:]
  if get(w:, 'cursorword_state', []) ==# [ linenr, word, enable ] | return | endif
  let w:cursorword_state = [ linenr, word, enable ]
  silent! call matchdelete(w:cursorword_id0)
  let w:cursorword_match = 0
  if !enable || word ==# '' || len(word) !=# strchars(word) && word !~# s:alphabets || len(word) > 1000 | return | endif
  let pattern = '\<' . escape(word, '~"\.^$[]*') . '\>'
  let w:cursorword_id0 = matchadd('CursorWord', pattern, -1)
  let w:cursorword_match = 1
endfunction

augroup cursorword
  autocmd!
  autocmd VimEnter,WinEnter,BufEnter,CursorMoved,CursorMovedI * call s:matchadd()
  autocmd InsertEnter * call s:matchadd(1)
  autocmd InsertLeave * call s:matchadd(0)
augroup END

let &cpo = s:save_cpo
unlet s:save_cpo
