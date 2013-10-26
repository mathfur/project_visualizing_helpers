let s:save_cpo = &cpo
set cpo&vim

let s:output_file = $HOME . "/.vim/CURRENT_LINE_LOG"

function! write_current_line#start_logging()
  " ONにする
  augroup WriteCurrentLineAutoLoggingGroup
    autocmd!
    autocmd CursorMoved * call write_current_line#appendfile([expand('%:p') . ':' . line('.')], s:output_file)
  augroup END
endfunction

function! write_current_line#stop_logging()
  " OFFにする
  augroup WriteCurrentLineAutoLoggingGroup
    autocmd!
  augroup 
endfunction

function! write_current_line#clear_log()
  call write_current_line#stop_logging()
  call writefile([], s:output_file)
endfunction

function! write_current_line#appendfile(lines, file)
  call writefile(readfile(a:file) + a:lines, a:file)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
