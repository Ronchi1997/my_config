"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Basic
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
syntax on
set nu
set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab
set autoindent
set smartindent
set hlsearch
set showcmd	  	" Show (partial) command in status line.
set showmatch		" Show matching brackets.
set smartcase		" Do smart case matching
set incsearch		" Incremental search
set nohidden
set noswapfile
set nobackup
set magic
set autoread
set autowrite
set autowriteall
set backspace=indent,eol,start
" ctags
set autochdir
set tags=tags;
nnoremap <F5> :call UpdateCtags()<CR>
function! UpdateCtags()
  let curdir = expand("%:p:h")
  execute ":cd `git rev-parse --show-toplevel`"
  !ctags -R --c++-kinds=+p --fields=+iaS --extra=+q $PWD
  execute ":cd " . curdir
endfunction

set background=dark
colorscheme solarized

set encoding=utf8
set ffs=unix

" Merge symbols
match ErrorMsg '^\(<\|=\|>\)\{7\}\([^=].\+\)\?$'

if $TERM_PROGRAM =~ "iTerm"
  let &t_SI = "\<Esc>]50;CursorShape=1\x7" " Vertical bar in insert mode
  let &t_SR = "\<Esc>]50;CursorShape=2\x7" " Underscore in replace mode
  let &t_EI = "\<Esc>]50;CursorShape=0\x7" " Block in normal mode
endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Key Mapping
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let mapleader=","
nnoremap <leader>, :tabnew<space>
nnoremap <leader>. gt
nnoremap <leader><esc> :q<CR>
map <silent> <leader><CR> :noh<CR>

nnoremap j jzz
nnoremap k kzz
nnoremap <c-h> <c-w>h
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-l> <c-w>l

vnoremap <silent> * :<c-u>call VisualSelection()<CR>/<CR>=@/<CR><CR>
vnoremap <silent> # :<c-u>call VisualSelection()<CR>?<CR>=@/<CR><CR>

inoremap <tab> <c-n>
inoremap ( ()<esc>i
inoremap ) <c-r>=ClosePair(')')<CR>
inoremap [ []<esc>i
inoremap ] <c-r>=ClosePair(']')<CR>
inoremap { {<CR>}<esc>O
inoremap " <c-r>=SamePair('"')<CR>
inoremap ' <c-r>=SamePair("'")<CR>

function! ClosePair(char)
  if getline('.')[col('.') - 1] == a:char
    return "\<Right>"
  else
    return a:char
  endif
endfunction
function! SamePair(char)
  let line = getline('.')
  if col('.') > strlen(line) || line[col('.') - 1] == ' '
    return a:char.a:char."\<esc>i"
  elseif line[col('.') - 1] == a:char
    return "\<Right>"
  else
    return a:char
  endif
endfunction
function! VisualSelection() range
  let l:saved_reg = @"
  execute "normal! vgvy"

  let l:pattern = escape(@", "\\/.*'$^~[]")
  let l:pattern = substitute(l:pattern, "\n$", "", "")

  let @/ = l:pattern
  let @" = l:saved_reg
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Plugins
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set nocompatible
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'
Plugin 'scrooloose/nerdtree'
Plugin 'majutsushi/tagbar'
Plugin 'itchyny/lightline.vim'
Plugin 'tpope/vim-fugitive'
call vundle#end()
filetype plugin indent on

" nerdtree
map <F7> : NERDTreeToggle<CR>

" nerdtree
map <F8> : TagbarToggle<CR>
let g:tagbar_autofocus = 1

" lightline
set laststatus=2
let g:lightline = {
      \ 'colorscheme': 'powerline',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'filename', 'readonly' ] ],
      \   'right': [ [ 'lineinfo' ],
      \              [ 'percent' ] ],
      \ },
      \ 'component_function': {
      \   'filename': 'LightlineFilename'
      \ },
      \ }

function! LightlineFilename()
  let gitbranch = fugitive#head() !=# '' ? fugitive#head() . ' > ' : ''
  let filename = expand("%:t") !=# '' ? expand("%:t") : ' [No Name] '
  let modified = &modified ? ' [+] ' : ''
  return gitbranch . filename . modified
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => AutoCmd
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if has("autocmd")
  " cursor stay at last exit when open
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
  " change dir when enter vim, work with autochdir
  au VimEnter * exec ":cd " . expand("%:p:h")
  " remove white-space EOL
  au BufWritePre * %s/\s\+$//e
endif
