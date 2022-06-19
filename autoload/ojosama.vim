vim9script
scriptencoding utf-8

g:ojosama_runtime = get(g:, 'ojosama_runtime', '')
g:ojosama_prompt = get(g:, 'ojosama_prompt', 'ξﾟ⊿ﾟ)ξ< ')

var _job: job
var resutls: list<string>

def Callback(_channel: channel, msg: string): void
  add(resutls, msg)
enddef

def ExitCallback(_: job, msg: number, winsaveview: dict<number>): void
  silent deletebufline('%', 1, '$')
  setline(1, resutls)
  winrestview(winsaveview)
enddef

def Execute(input: string, winsaveview: dict<number>): void
  _job = job_start(g:ojosama_runtime, {
    callback: (c, m) => Callback(c, m),
    exit_cb: (c, m) => ExitCallback(c, m, winsaveview),
    in_mode: 'nl',
  })

  const channel = job_getchannel(_job)
  if ch_status(channel) ==# 'open'
    ch_sendraw(channel, input)
    ch_close_in(channel)
  endif
enddef

def Echo(_, msg: string): void
  echomsg g:ojosama_prompt .. msg
enddef

export def Format(...args: list<any>): void
  if exists('job') && job_status(_job) !=# 'stop'
    call job_stop(_job)
  endif
  resutls = []
  const winsaveview = winsaveview()

  const bufnum = bufnr('%')
  const input = join(getbufline(bufnum, 1, '$'), "\n") .. "\n"

  Execute(input, winsaveview)
enddef

export def Say(...args: list<any>): void
  if g:ojosama_runtime ==# ''
    Echo('', 'Please install ojosama from https://github.com/jiro4989/ojosama')
    return
  endif
  const input = args[0]
  if input ==# ''
    Format(args)
    return
  endif
  if exists('job') && job_status(_job) !=# 'stop'
    call job_stop(_job)
  endif
  _job = job_start(printf('%s -t %s', g:ojosama_runtime, input), {callback: Echo})
enddef
