vim.cmd([[
augroup fortran_settings
  autocmd!
	autocmd FileType fortran set foldmethod=syntax
  autocmd FileType fortran nnoremap <buffer> <localleader>c 0i!<esc>j
"  autocmd FileType fortran nnoremap <buffer> <localleader>wf :execute(":call ElmerFortranRegion('FUNCTION')")<cr>7kf(a
"  autocmd FileType fortran nnoremap <buffer> <localleader>ws :execute(":call ElmerFortranRegion('SUBROUTINE')")<cr>7kf(a
"  autocmd FileType fortran nnoremap <buffer> <localleader>wm :execute(":call ElmerFortranRegion('MODULE')")<cr>4ka
  autocmd FileType fortran set tabstop=2 softtabstop=0 expandtab shiftwidth=2 smarttab conceallevel=1
  autocmd FileType fortran syntax match FortranConceal '%' conceal cchar=→
augroup END
"]])
