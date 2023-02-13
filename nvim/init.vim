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
Plug 'vim-scripts/jade.vim'
Plug 'tpope/vim-fugitive'
Plug 'https://github.com/ettaka/vim-apdl.git'
Plug 'mg979/vim-visual-multi', {'branch':'master'}
Plug 'ettaka/vim-apdl'
" Plug 'ettaka/nvim-lua-plugin-test', {'branch':'main'}
" Telescope
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'neovim/nvim-lspconfig'
Plug 'nvim-lua/completion-nvim'
Plug 'untitled-ai/jupyter_ascending.vim'
Plug 'ER-solutions/jupyter-nvim'
" completion
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'
" For vsnip users.
Plug 'hrsh7th/cmp-vsnip'
Plug 'hrsh7th/vim-vsnip'
Plug 'jose-elias-alvarez/null-ls.nvim', {'branch':'main'}
call plug#end()
" }}}
" Basic settings ---------- {{{
set clipboard+=unnamedplus 
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
" Set a key-mapping for copy and pasting to the system clipboard
:vnoremap <Leader>y "+y
:nnoremap <Leader>p "+p
" inoremap jj <esc>
" inoremap <esc> <nop>
tnoremap <leader><esc> <C-\><C-n>
nnoremap <C-J> <C-W><C-J>:res<cr>
nnoremap <C-K> <C-W><C-K>:res<cr>
nnoremap <C-L> <C-W><C-L>:res<cr>
nnoremap <C-H> <C-W><C-H>:res<cr>
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
" Test Mappings ---------- {{{
command! -nargs=1 Dsaveas saveas %:p:h/<args>
" }}}
" Python file settings ---------- {{{
" Run split terminal at current path -------------------------{{{
" Create a function to open a neovim terminal in a small split window and run python 
function! Termrun()
	let @a="conda activate kqcircuits; cd ".expand('%:p:h')
	exec winheight(0)/4."split" | terminal 
endfunction
autocmd FileType python nnoremap <leader>t :call Termrun()<CR>"api<CR>
" }}}
" Run python in split terminal -------------------------{{{
" Create a function to open a neovim terminal in a small split window and run python 
function! Termpy()
	let @a="conda activate kqcircuits; cd ".expand('%:p:h').";python ".expand('%:t')
	exec "split" | terminal 
endfunction

function! TermKlayoutPy()
	let @a="conda activate kqcircuits; cd ".expand('%:p:h').";klayout -z -r ".expand('%:t')
	exec "split" | terminal 
endfunction

function! TermKQCSim()
	let @a="module load elmer/devel;conda activate kqcircuits; cd ".expand('%:p:h').";python $KQC/klayout_package/python/scripts/simulations/export_and_run.py ".expand('%:t')." -q"
	exec "split" | terminal 
endfunction
" }}}
augroup filetype_python
  autocmd!
  autocmd FileType python nnoremap <buffer> <localleader>c I# <esc>j
	autocmd FileType python map <buffer> <F9> :w<CR>:exec '!python3' shellescape(@%, 1)<CR>
  autocmd FileType python imap <buffer> <F9> <esc>:w<CR>:exec '!python3' shellescape(@%, 1)<CR>
  autocmd FileType python nnoremap <leader><CR> :call Termpy()<CR>"api<CR><C-\><C-n>Giexit
  autocmd FileType python nnoremap <leader>k<CR> :call TermKlayoutPy()<CR>"api<CR><C-\><C-n>Giexit
  autocmd FileType python nnoremap <leader>s<CR> :call TermKQCSim()<CR>"api<CR><C-\><C-n>Giexit
augroup END
" }}}
" sh file settings ---------- {{{
" Run split terminal at current path -------------------------{{{
" Create a function to open a neovim terminal in a small split window and run python 
function! Termrunsh()
	let @a="cd ".expand('%:p:h')
	exec winheight(0)/4."split" | terminal 
endfunction
autocmd FileType shell nnoremap <leader>t :call Termrunsh()<CR>"api<CR>
" }}}
" Run shell script in split terminal -------------------------{{{
" Create a function to open a neovim terminal in a small split window and run python 
function! Termsh()
	let @a="cd ".expand('%:p:h').";./".expand('%:t')
	exec "split" | terminal 
endfunction
" }}}
augroup filetype_shell
  autocmd!
  autocmd FileType sh nnoremap <leader><CR> :call Termsh()<CR>"api<CR><C-\><C-n>Giexit
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
set guicursor= " This is needed for tmux
" vim-visual-multi -------------------------{{{
let g:VM_leader = '\\'
" }}}
" Telescope -------------------------{{{
" Find files using Telescope command-line sugar.
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>
nnoremap <leader>f* yiw<cmd>Telescope grep_string<cr><C-R>"
vnoremap <leader>f* y:Telescope grep_string<CR><C-r>"
" }}}
" LSP servers -------------------------{{{
lua << EOF
require'lspconfig'.fortls.setup{}
EOF
lua << EOF
--require'lspconfig'.pyright.setup{}
require'lspconfig'.pylsp.setup{}
EOF
" use omni completion provided by lsp
" autocmd Filetype python setlocal omnifunc=v:lua.vim.lsp.omnifunc

nnoremap <silent> <c-]> <cmd>lua vim.lsp.buf.declaration()<CR>
nnoremap <silent> gd    <cmd>lua vim.lsp.buf.definition()<CR>
nnoremap <silent> K     <cmd>lua vim.lsp.buf.hover()<CR>
nnoremap <silent> gD    <cmd>lua vim.lsp.buf.implementation()<CR>
nnoremap <silent> 1gD   <cmd>lua vim.lsp.buf.type_definition()<CR>
nnoremap <silent> gr    <cmd>lua vim.lsp.buf.references()<CR>
nnoremap <silent> g0    <cmd>lua vim.lsp.buf.document_symbol()<CR>
nnoremap <silent> gW    <cmd>lua vim.lsp.buf.workspace_symbol()<CR>

" }}}
" Completion-------------------------{{{
set completeopt=menu,menuone,noselect

lua <<EOF
  -- Setup nvim-cmp.
  local cmp = require'cmp'

  cmp.setup({
    snippet = {
      -- REQUIRED - you must specify a snippet engine
      expand = function(args)
        vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
        -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
        -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
        -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
      end,
    },
    mapping = {
      ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
      ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
      ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
      ['<C-y>'] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
      ['<C-e>'] = cmp.mapping({
        i = cmp.mapping.abort(),
        c = cmp.mapping.close(),
      }),
      ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    },
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'vsnip' }, -- For vsnip users.
      -- { name = 'luasnip' }, -- For luasnip users.
      -- { name = 'ultisnips' }, -- For ultisnips users.
      -- { name = 'snippy' }, -- For snippy users.
    }, {
      { name = 'buffer' },
    })
  })

  -- Set configuration for specific filetype.
  cmp.setup.filetype('gitcommit', {
    sources = cmp.config.sources({
      { name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it.
    }, {
      { name = 'buffer' },
    })
  })

  -- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline('/', {
    sources = {
      { name = 'buffer' }
    }
  })

  -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline(':', {
    sources = cmp.config.sources({
      { name = 'path' }
    }, {
      { name = 'cmdline' }
    })
  })

  -- Setup lspconfig.
  local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
  -- Replace <YOUR_LSP_SERVER> with each lsp server you've enabled.
  require('lspconfig')['pylsp'].setup {
    capabilities = capabilities
  }
EOF
" }}}
" null-ls (linter)-------------------------{{{
lua << EOF
require("null-ls").setup({
    sources = {
        require("null-ls").builtins.diagnostics.pylint,
    },
})
EOF
" }}}
" Utilities for Jupyter notebooks-------------------------{{{
"
nmap <space><space>x <Plug>JupyterExecute
nmap <space><space>X <Plug>JupyterExecuteAll
" lua require("jupyter-nvim").set_test_mappings()

" }}}

" for nvim 7.0
" https://youtu.be/jH5PNvJIa6o
" set laststatus=3
" highlight WinSeparator guibg=None
