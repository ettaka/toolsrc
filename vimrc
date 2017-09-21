set nocompatible              " be iMproved, required
filetype off                  " required
set backspace=indent,eol,start
set updatetime=250

" 
" " Vundle stuff---------- {{{
" set rtp+=~/.vim/bundle/Vundle.vim
" call vundle#begin()
" " let Vundle manage Vundle, required
" Plugin 'VundleVim/Vundle.vim'
" Plugin 'Valloric/YouCompleteMe'
" Plugin 'tpope/vim-fugitive'
" Plugin 'scrooloose/nerdtree'
" Plugin 'kchmck/vim-coffee-script'
" Plugin 'digitaltoad/vim-jade'
" Plugin 'wavded/vim-stylus'
" Plugin 'ettaka/vim-elmer'
" Plugin 'ctrlpvim/ctrlp.vim'
" Plugin 'airblade/vim-gitgutter' 
" Plugin 'godlygeek/tabular' 
" "Plugin 'terryma/vim-multiple-cursors'
" "
" call vundle#end()            " required
" " }}}
" 
" Basic settings ---------- {{{
filetype plugin indent on    " required
syntax on
set number
set foldlevelstart=0
set ruler
" }}}
" Mappings ---------- {{{
let mapleader = "\\"
noremap <leader>- ddp
noremap <leader>_ dd2kp
inoremap <leader><c-u> <esc>viwUi
nnoremap <leader><c-u> viwU
nnoremap <leader>ev :vsplit $MYVIMRC<cr>
nnoremap <leader>sv :source $MYVIMRC<cr>
nnoremap <leader>" viw<esc>a"<esc>bi"<esc>
nnoremap <leader>' viw<esc>a'<esc>bi'<esc>
nnoremap <leader>; `<i'<esc>`>a'<esc>
nnoremap <leader>H 0
nnoremap <leader>L $
nnoremap § :silent !make<cr>:redr!<cr>
inoremap jj <esc>
" }}}
" Test Mappings ---------- {{{
nnoremap <BS> :w<cr>
" }}}
iabbrev @@ eelis.takala@gmail.com
" Python file settings ---------- {{{
augroup filetype_python
  autocmd!
  autocmd FileType python nnoremap <buffer> <localleader>c I#<esc>
augroup END
" }}}
" Vimscript file settings ---------- {{{
augroup filetype_vim
  autocmd!
  autocmd FileType vim setlocal foldmethod=marker
  autocmd FileType vim setlocal tabstop=2
  autocmd FileType vim setlocal shiftwidth=2
  autocmd FileType vim nnoremap <buffer> <localleader>c 0i" <esc>
augroup END
" }}}
" Jade file settings ---------- {{{
augroup filetype_jade
  autocmd!
  autocmd FileType jade setlocal foldmethod=marker
  autocmd FileType jade setlocal expandtab
  autocmd FileType jade setlocal tabstop=2
  autocmd FileType jade setlocal shiftwidth=2
  autocmd FileType jade nnoremap <buffer> <localleader>c 0i// <esc>
augroup END
" }}}
" Coffee file settings ---------- {{{
augroup filetype_coffee
  autocmd!
  autocmd FileType coffee setlocal foldmethod=marker
  autocmd FileType coffee setlocal expandtab
  autocmd FileType coffee setlocal tabstop=2
  autocmd FileType coffee setlocal shiftwidth=2
  autocmd FileType coffee nnoremap <buffer> <localleader>c 0i# <esc>
augroup END
" }}}
nnoremap <leader>f :call FoldColumnToggle()<cr>
function! FoldColumnToggle()
	if &foldlevel
		setlocal foldlevel=0
	else
		setlocal foldlevel=1
	endif
endfunction

" Latex file settings ---------- {{{
"augroup filetype_tex
"	autocmd!
"	autocmd FileType tex nnoremap <BS> :silent !latex %<cr>:redr!<cr>
"augroup END
" }}}
