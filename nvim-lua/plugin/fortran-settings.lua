vim.cmd([[
augroup fortran_settings
  autocmd!
  autocmd FileType fortran set foldmethod=syntax
  autocmd FileType fortran nnoremap <buffer> <localleader>c 0i!<esc>j
  autocmd FileType fortran set tabstop=2 softtabstop=0 expandtab shiftwidth=2 smarttab conceallevel=1
  autocmd FileType fortran syntax keyword FortranConceal call conceal cchar=📞
  autocmd FileType fortran syntax match FortranConceal '%' conceal cchar=→
  autocmd FileType fortran set concealcursor=niv
augroup END
"]])
