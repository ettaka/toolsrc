set nocompatible              " be iMproved, required
filetype off                  " required

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'
Plugin 'tpope/vim-fugitive'
Plugin 'scrooloose/nerdtree'

call vundle#end()            " required
filetype plugin indent on    " required
syntax on
set number

" learn Vim the hard way stuff>
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
inoremap jj <esc>
inoremap <esc> <nop>
iabbrev @@ eelis.takala@gmail.com
