" scratch.vim
" Author: Abhilash Koneri (abhilash_koneri at hotmail dot com)
" Improved By: Hari Krishna Dara (hari_vim at yahoo dot com)
" Last Change: 25-Feb-2004 @ 09:48
" Created: 17-Aug-2002
" Version: 1.0.0
"   1.0.0ingo004  15-Dec-2010   Fixing window height to &previewheight. 
"   1.0.0ingo003  14-Mar-2010   Maintaining the alternate file via :keepalt. 
"                               Now requiring Vim 7.0 or higher. 
"   1.0.0ingo002  23-May-2009   BF: Toggling off applied scratch buffer settings
"                               to another buffer. Skipping buffer settings in
"                               that case. 
"   1.0.0ingo001  19-May-2009   Changed semantics to match other "sidebar"
"                               plugins (project.vim, bufexplorer.vim,
"                               taglist.vim). 
" Download From:
"     http://www.vim.org/script.php?script_id=389
"----------------------------------------------------------------------
" This is a simple plugin that creates a scratch buffer for your
" vim session and helps to access it when you need it.  
"
" If you like the custom mappings provided in the script - hitting
" <F8> should create a new scratch buffer. You can do your scribes
" here and if you want to get rid of it, hit <F8> again inside scratch buffer
" window. If you want to get back to the scratch buffer repeat <F8>. Use
" <Plug>ShowScratchBuffer and <Plug>InsShowScratchBuffer to customize these
" mappings.
"
" If you want to designate a file into which the scratch buffer contents
" should automatically be dumped to, when Vim exits, set its path to
" g:scratchBackupFile global variable. This file can be accessed just in case
" you happen to have some important information in the scratch buffer and quit
" Vim (or shutdown the m/c) forgetting to copy it over. The target file is
" force overwritten using the :write! command so make sure you set a file name
" that can accidentally be used for other purposes (especially when you use
" relative paths). I recommend a value of '/tmp/scratch.txt'.
" CAUTION: This feature works only when Vim generates VimLeavePre autocommad.
"
" Custom mappings
" ---------------
" The ones defined below are not very ergonomic!
"----------------------------------------------------------------------
"Standard Inteface:  <F8> to make a new ScratchBuffer, <F8>-again to hide one

if exists('loaded_scratch') || (v:version < 700) 
  finish
endif
let loaded_scratch = 1

" Make sure line-continuations won't cause any problem. This will be restored
"   at the end
let s:save_cpo = &cpo
set cpo&vim

if (! exists("no_plugin_maps") || ! no_plugin_maps) &&
      \ (! exists("no_scratch_maps") || ! no_scratch_maps)
  if !hasmapto('<Plug>ShowScratchBuffer',"n")
    nmap <unique> <silent> <F8> <Plug>ShowScratchBuffer
  endif
  if !hasmapto('<Plug>InsShowScratchBuffer',"i")
    imap <unique> <silent> <F8> <Plug>InsShowScratchBuffer
  endif
endif

" User Overrideable Plugin Interface
nmap <script> <silent> <Plug>ShowScratchBuffer
      \ :silent call <SID>ShowScratchBuffer()<cr>
imap <script> <silent> <Plug>InsShowScratchBuffer
      \ <c-o>:silent call <SID>ShowScratchBuffer()<cr>

command! -nargs=0 Scratch :call <SID>ShowScratchBuffer()

if !exists('g:scratchBackupFile')
  let g:scratchBackupFile = '' " So that users can easily find this var.
endif
aug ScratchBackup
  au!
  au VimLeavePre * :call <SID>BackupScratchBuffer()
aug END

let s:SCRATCH_BUFFER_NAME="[Scratch]"
if !exists('s:buffer_number') " Supports reloading.
  let s:buffer_number = -1
endif

"----------------------------------------------------------------------
" Toggles the scratch buffer. Creates one if it is not already 
" present, shows if not yet visible, hides if it was already loaded in a window. 
"----------------------------------------------------------------------
function! <SID>ShowScratchBuffer()
  if(s:buffer_number == -1 || bufexists(s:buffer_number) == 0)
    " No scratch buffer has been created yet. 
    " Temporarily modify isfname to avoid treating the name as a pattern.
    let _isf = &isfname
    set isfname-=\
    set isfname-=[
    if exists('+shellslash')
      exec "keepalt topleft sp \\\\". s:SCRATCH_BUFFER_NAME
    else
      exec "keepalt topleft sp \\". s:SCRATCH_BUFFER_NAME
    endif
    let &isfname = _isf
    let s:buffer_number = bufnr('%')
  else
    " A scratch buffer already exists ... 
    let buffer_win=bufwinnr(s:buffer_number)
    if(buffer_win == -1)
      " ... but isn't visible, so show it. 
      exec 'topleft' &previewheight.'split'
      exec 'keepalt buf' s:buffer_number
    else
      " ... and is visible, so close it. 
      exec buffer_win.'wincmd w'
      hide
      wincmd p
      return
    endif
  endif
  " Do setup always, just in case.
  setlocal buftype=nofile
  setlocal bufhidden=hide
  setlocal nobuflisted
  setlocal noswapfile
  setlocal noro
endfunction

function! s:BackupScratchBuffer()
  if s:buffer_number != -1 && exists('g:scratchBackupFile') &&
        \ g:scratchBackupFile != ''
    exec 'keepalt split #' . s:buffer_number
    " Avoid writing empty scratch buffers.
    if line('$') > 1 || getline(1) !~ '^\s*$'
      exec 'keepalt write!' g:scratchBackupFile
    endif
  endif
endfunction

" Restore cpo.
let &cpo = s:save_cpo
unlet s:save_cpo

" vim6: sw=2 et
