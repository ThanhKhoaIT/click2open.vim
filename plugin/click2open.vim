" @Author:      Khoa Nguyen (thanhkhoa.it@gmail.com)
" @Created:     2020-11-03

let s:channel_supported = exists('*ch_open')
let s:job_supported = exists('*job_start')
let s:github_remote = ''
let s:channel = 0

autocmd VimEnter * call timer_start(2000, function('s:InitClick2Open'), { 'repeat': -1 })

function! s:InitClick2Open(_timer)
  if !s:channel_supported
    echo 'You VIM not support channel'
    return
  endif

  if !s:job_supported
    echo 'You VIM not support job'
    return
  endif

  if type(s:channel) == 9 && ch_status(s:channel) == 'open' | return | endif

  silent let s:channel = ch_open('0.0.0.0:62032') " Socket connect to Chrome App
  silent call job_start(['git', 'remote', '-v'], { 'callback': 'C2OAssignGithubRemote' })
endfunction

function! Click2OpenFile(file, line, remote)
  if a:file == 'undefined' | return | endif
  if s:SkippedByRemote(a:remote)
    echo 'Click2Open: Ignored with repository ' . a:remote
    return 'skipped'
  endif

  if !filereadable(a:file)
    echo 'Click2Open: Ignored with file is not exists ' . a:file
    return 'skipped'
  endif

  if &modified
    execute 'tabedit ' . a:file
  else
    execute 'edit ' . a:file
  endif

  if a:line | execute a:line | endif

  return 'done'
endfunction

function! C2OAssignGithubRemote(_channel, link)
  let s:github_remote = matchstr(a:link, ':.*\.git')[1:-5]
endfunction

function! s:SkippedByRemote(remote)
  if a:remote == 'SKIP_TO_CHECK_REPOSITORY' | return 0 | endif
  return a:remote != s:github_remote
endfunction
