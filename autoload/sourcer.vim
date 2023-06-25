let g:findSourceEnableDebugMessage = 1

function! sourcer#OpenTheSourceUnderCursor()
  if s:FindFromImportLine()
    return
  endif

  if s:FindFromExactWordStrategy()
    return
  endif

  if s:FindFromFuzzyEndStrategy()
    return
  endif

  echom "Not found any source map with name: " . expand('<cword>')
endfunction

function s:FindFromFuzzyEndStrategy()
  " If no results found, process searching the file which has current word *
  let queryStringFuzzyTheEnd = s:BuildQueryString('fuzzy-end')
  echomsg l:queryStringFuzzyTheEnd

  let resultsFromFind = systemlist(expand(l:queryStringFuzzyTheEnd))

  let results = s:FilterFoundResults(l:resultsFromFind)

  if len(results) == 1
    execute "edit " results[0]
    call s:debug("Found one result from fuzzy-end strategy. File: " . results[0])
    return 1
  endif

  if len(results) > 1
    call fzf#run(fzf#wrap({'source': expand(l:queryStringFuzzyTheEnd)}))
    call s:debug( "Found more results from fuzzy-end strategy")
    return 1
  endif

  return 0
endfunction

function s:FindFromExactWordStrategy()
  " If no results found, process searching the file which has exact the current word
  let queryStringExactName = s:BuildQueryString('exact-word')
  let resultsFromFind = systemlist(expand(l:queryStringExactName))

  let results = s:FilterFoundResults(resultsFromFind)

  if len(results) == 1
    execute ":edit " results[0]
    call s:debug("Found one result from exact-word strategy . File: " . results[0])
    return 1
  endif

  if len(results) > 1
    " open a fuzzy finder helping user choose the file with type of 'CurrentWord*' which has more than 2 results found
    call fzf#run(fzf#wrap({'source': expand(l:queryStringExactName)}))
    call s:debug("Found more results from exact-word strategy")
    return 1
  endif

  return 0
endfunction

function s:FindFromImportLine()
  " Handle for the case the cursor is at `import` line - current limit is only open java, but happy case is if not found then trying to find a file name match to current word -> the result is mostly kotlin
  " getline('.') import org.springframework.http.HttpStatus
  let words = split(getline('.'), '\W\+') " [import, org, spring, http, HttpStatus]
  if words[0] != 'import' " early return if we're not on the `import` line
    return 0
  endif

  let buildRelativeSourcePath  = join(words[1:], '/') " words[1:] to remove the import word: org, spring, http, HttpStatus => result: org/spring/http/HttpStatus
  let absoluteSourcePath = g:libPath . '/' . buildRelativeSourcePath . '.java'

  " expand(l:absoluteSourcePath) => filereadable accepts a string => this is to turn absoluteSourcePath to a string
  if filereadable(expand(l:absoluteSourcePath)) " check file exists then open it up
    execute ":edit " absoluteSourcePath
    call s:debug("Found from library source path")
    return 1
  endif

  let currentProjectSourcePath = getcwd() . '/src/main/java/' . buildRelativeSourcePath . '.java'
  if filereadable(expand(l:currentProjectSourcePath)) " check file exists then open it up
    execute ":edit " currentProjectSourcePath
    call s:debug("Found from current project source path")
    return 1
  endif

  return 0
endfunction

function s:debug(message)
  if g:findSourceEnableDebugMessage
    echo a:message
  endif
endfunction

function s:BuildQueryString(queryType)
  let query = ''
  if getcwd() == g:libPath
    let query .= "rg --files " . g:libPath
  else
    let query .= "rg --files . " . g:libPath " maybe replace . with getcwd() but for easier differenticate from the results which sources from current folder or lib, just let be there
  endif

  if a:queryType == 'exact-word'
    let query .= " | rg '" . expand('<cword>') . ".java'"
  elseif a:queryType == 'fuzzy-end'
    let query .= " | rg '" . expand('<cword>') . "*'"
  else
    throw 'No queryType from function BuildQueryString match'
  endif

  return query
endfunction

function s:FilterFoundResults(results)
  return filter(a:results, 'v:val !~ "Permission denied"') " filter array of strings which contains 'Permission denied'
endfunction
