vim9script

if v:version < 802 && has('patch-8.2.4656')
  echoerr 'ojosama.vim requires Vim version 9.0+.'
  finish
endif

import autoload 'ojosama.vim'

command! -buffer -nargs=* -range=0
      \ Ojosama ojosama.Say(<q-args>, <count>, <line1>, <line2>)
