" Currently support java and kotlin
let g:findSourceJavaLibPath = $HOME . '/dev/software/sources/java'
let g:findSourceEnableDebugMessage = 1 " 0 means false, otherwise true

function! sourcer#openTheSourceUnderCursor()
  if s:findFromImportLine()
    return
  endif

  if s:findFromExactWordStrategy()
    return
  endif

  if s:findFromFuzzyEndStrategy()
    return
  endif

  echom "Not found any source map with name: " . expand('<cword>')
endfunction

function s:findFromFuzzyEndStrategy()
  " If no results found, process searching the file which has current word *
  let queryStringFuzzyTheEnd = s:buildQueryString('fuzzy-end')
  let resultsFromFind = system(expand(l:queryStringFuzzyTheEnd))

  let results = s:filterFoundResults(split(resultsFromFind, "\n"))

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

function s:findFromExactWordStrategy()
  " If no results found, process searching the file which has exact the current word
  let queryStringExactName = s:buildQueryString('exact-word')
  let resultsFromFind = system(expand(l:queryStringExactName))

  let results = s:filterFoundResults(split(resultsFromFind, "\n"))

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

function s:findFromImportLine()
  " Handle for the case the cursor is at `import` line - current limit is only open java, but happy case is if not found then trying to find a file name match to current word -> the result is mostly kotlin
  " getline('.') import org.springframework.http.HttpStatus
  let words = split(getline('.'), '\W\+') " [import, org, spring, http, HttpStatus]
  if words[0] != 'import' " early return if we're not on the `import` line
    return 0
  endif

  let buildRelativeSourcePath  = join(words[1:], '/') " words[1:] to remove the import word: org, spring, http, HttpStatus => result: org/spring/http/HttpStatus
  let absoluteSourcePath = g:findSourceJavaLibPath . '/' . buildRelativeSourcePath . '.java'

  " expand(l:absoluteSourcePath) => filereadable accepts a string => this is to turn absoluteSourcePath to a string
  if filereadable(expand(l:absoluteSourcePath)) " check file exists then open it up
    execute ":edit " absoluteSourcePath
    call s:debug("Found from library source path")
    return 1
  endif

  let currentProjectSourcePath = getcwd() . '/app/src/main/kotlin/' . buildRelativeSourcePath . '.kt'
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

function s:buildQueryString(queryType)
  let query = ''
  if getcwd() == g:findSourceJavaLibPath
    let query .= "find " . g:findSourceJavaLibPath
  else
    let query .= "find . " . g:findSourceJavaLibPath " maybe replace . with getcwd() but for easier differenticate from the results which sources from current folder or lib, just let be there
  endif

  let query .= " -type f -not -path '*.git*' -not -path '*app/build*' -not -path '*app/gradle*' -not -path '*app/output*' -not -path '*app/.gradle-home*' -not -path '*data/db*'"
  if a:queryType == 'exact-word'
    let query .= " -name '" . expand('<cword>') . ".kt' -o -name '" . expand('<cword>') . ".java'"
  elseif a:queryType == 'fuzzy-end'
    let query .= " -name '" . expand('<cword>') . "*'"
  else
    throw 'No queryType from function buildQueryString match'
  endif

  return query
endfunction

function s:filterFoundResults(results)
  return filter(a:results, 'v:val !~ "Permission denied"') " filter array of strings which contains 'Permission denied'
endfunction
