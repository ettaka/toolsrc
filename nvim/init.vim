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
Plug 'scrooloose/nerdtree'
Plug 'gcmt/taboo.vim'
Plug 'vim-scripts/vim-coffee-script'
Plug 'digitaltoad/vim-pug'
Plug 'mg979/vim-visual-multi', {'branch': 'master'}
Plug 'pangloss/vim-javascript'
Plug 'ternjs/tern_for_vim', { 'do' : 'npm install' }
Plug 'tpope/vim-fugitive'
Plug 'ettaka/vim-apdl'
Plug 'ettaka/nvim-lua-plugin-test', {'branch':'main'}


Plug 'neovim/nvim-lspconfig'
Plug 'nvim-lua/completion-nvim'
call plug#end()
" }}}
" Basic settings ---------- {{{
filetype plugin indent on    " required
set omnifunc=syntaxcomplete#Complete
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
nnoremap <esc> :NERDTreeToggle<cr>
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
	autocmd FileType python map <buffer> <F9> :w<CR>:exec '!python3' shellescape(@%, 1)<CR>
  autocmd FileType python imap <buffer> <F9> <esc>:w<CR>:exec '!python3' shellescape(@%, 1)<CR>
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

let g:python3_host_prog="/home/eelis/miniconda3/bin/python"
"let g:python3_host_prog="/home/eelis/miniconda2/envs/neovim3/bin/python3"

set guicursor= " This is needed for tmux

" vim visual multi -------------------------{{{
let g:VM_leader='\\'
" }}}
" Completion stuff -------------------------{{{
:lua << EOF
  local nvim_lsp = require('lspconfig')
	nvim_lsp.pyls.setup{on_attach=require'completion'.on_attach}
  nvim_lsp.bashls.setup{on_attach=require'completion'.on_attach}
  nvim_lsp.fortls.setup{on_attach=require'completion'.on_attach}
EOF
" Use <Tab> and <S-Tab> to navigate through popup menu
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

" Set completeopt to have a better completion experience
set completeopt=menuone,noinsert,noselect

" Avoid showing message extra message when using completion
set shortmess+=c
" }}}

