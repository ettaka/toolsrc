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
Plug 'godlygeek/tabular'

" autocompletion
"Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
"Plug 'zchee/deoplete-jedi'

Plug 'scrooloose/nerdtree'
Plug 'gcmt/taboo.vim'
Plug 'vim-scripts/vim-coffee-script'
Plug 'vim-scripts/jade.vim'
Plug 'tpope/vim-fugitive'
Plug 'https://github.com/ettaka/vim-apdl.git'
Plug 'mg979/vim-visual-multi', {'branch':'master'}
call plug#end()
" }}}
" Basic settings ---------- {{{
filetype plugin indent on    " required
syntax on
set number
set foldlevelstart=0
set ruler
colorscheme carbonized-dark
" au FocusGained,BufEnter * checktime " autoread works only if this is on
" }}}
" Neomake stuff -------------------{{{
" autocmd User NeomakeFinished copen
nnoremap <leader>my :NeomakeSh printf "y" \| compile\_elmer\_branch.sh<cr>
nnoremap <leader>mn :NeomakeSh printf "N\ny" \| compile\_elmer\_branch.sh<cr>
nnoremap <leader>l :NeomakeSh ./run_latex.sh<cr>
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
nnoremap ; :
inoremap jj <esc>
inoremap <esc> <nop>
tnoremap jj <C-\><C-n>

nnoremap <C-J> <C-W><C-J>:res<cr>
nnoremap <C-K> <C-W><C-K>:res<cr>
nnoremap <C-L> <C-W><C-L>:res<cr>
nnoremap <C-H> <C-W><C-H>:res<cr>
" }}}
" Test Mappings ---------- {{{
tnoremap <leader>cd <C-\><C-n>kyy:cd <C-R>" <CR>
" Search for selected text, forwards or backwards.
vnoremap <silent> * :<C-U>
  \let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
  \gvy/<C-R><C-R>=substitute(
  \escape(@", '/\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
  \gV:call setreg('"', old_reg, old_regtype)<CR>
vnoremap <silent> # :<C-U>
  \let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
  \gvy?<C-R><C-R>=substitute(
  \escape(@", '?\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
  \gV:call setreg('"', old_reg, old_regtype)<CR>
" }}}
"
" Python file settings ---------- {{{
augroup filetype_python
  autocmd!
  autocmd FileType python nnoremap <buffer> <localleader>c I#<esc>j
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
let fortran_fold=1
" }}}

let g:python_host_prog="/home/eelis/miniconda2/envs/neovim2/bin/python"
"let g:python3_host_prog="/home/eelis/miniconda2/envs/neovim3/bin/python3"

set guicursor= " This is needed for tmux
let g:deoplete#enable_at_startup = 1

" vim-visual-multi -------------------------{{{
let g:VM_leader = '\\'

" }}}
