command! -nargs=? -bar JavaFindSources lua require('java-source-finder').run(<f-args>)
command! JavaSyncSources execute 'terminal ' . g:installedJavaSourcePluginPath . '/bin/sync_sources.sh ' . g:libPath . ' ' . g:libRepository . ' ' g:javaHomeSrcZipPath
