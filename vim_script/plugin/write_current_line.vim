if exists("g:loaded_write_current_line")
  finish
endif
let g:loaded_write_current_line = 1

let s:save_cpo = &cpo
set cpo&vim

command! -nargs=0 StartCurrentLineLogging call write_current_line#start_logging()
command! -nargs=0 StopCurrentLineLogging  call write_current_line#stop_logging()
command! -nargs=0 ClearCurrentLineLog     call write_current_line#clear_log()

let &cpo = s:save_cpo
unlet s:save_cpo
