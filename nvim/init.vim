set nocompatible              " be iMproved, required
filetype off                  " required
iabbrev @@ eelis.takala@gmail.com

" vim-plug settings ---------- {{{
call plug#begin()
Plug 'ettaka/vim-elmer'
" Plug 'BurningEther/nvimux'
Plug 'Neomake/neomake'
Plug 'rafi/awesome-vim-colorschemes'
Plug 'vim-scripts/CSApprox'
call plug#end()
" }}}
" Basic settings ---------- {{{
filetype plugin indent on    " required
syntax on
set number
set foldlevelstart=0
set ruler
colorscheme carbonized-dark
" }}}
" Neomake stuff -------------------{{{
autocmd User NeomakeFinished copen
nnoremap <leader>my :NeomakeSh printf "y" \| compile\_elmer\_branch.sh<cr>
nnoremap <leader>mn :NeomakeSh printf "N\ny" \| compile\_elmer\_branch.sh<cr>
" }}}
" Basic mappings ---------- {{{
let mapleader = "\\"
noremap <leader>- ddp
noremap <leader>_ dd2kp
inoremap <leader><c-u> <esc>viwUi
nnoremap <leader><c-u> viwU
nnoremap <leader>ev :vsplit ~/.config/nvim/init.vim<cr>
nnoremap <leader>sv :source ~/.config/nvim/init.vim<cr>
nnoremap <leader>" viw<esc>a"<esc>bi"<esc>
nnoremap <leader>' viw<esc>a'<esc>bi'<esc>
nnoremap <leader>; `<i'<esc>`>a'<esc>
nnoremap <leader>H 0
nnoremap <leader>L $
inoremap jj <esc>
inoremap <esc> <nop>
tnoremap jj <C-\><C-n>

nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>
" }}}
" Test Mappings ---------- {{{
nnoremap <leader>g :silent execute ":grep -R " . shellescape(expand("<cWORD>")) . " ."<cr>
     \:execute "copen 5"<cr>
" }}}
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
" Folding -------------------------{{{
noremap <leader>f :call FoldColumnToggle()<cr>
function! FoldColumnToggle()
	if &foldlevel
		setlocal foldlevel=0
	else
		setlocal foldlevel=1
	endif
endfunction
" }}}
let g:python_host_prog="python"
