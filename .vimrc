syntax enable
set t_Co=256
set background=dark
colorscheme solarized

"Spaces and Tabs
set tabstop=4
set softtabstop=4
set expandtab
set shiftwidth=4
filetype plugin indent on

"Backspace across lines
set backspace=indent,eol,start

"UI settings
set number
set showcmd
set cursorline
filetype indent on
set wildmenu
set showmatch "show matching ([{}])

"Searching
set incsearch
set hlsearch

"Switching between buffers
:nnoremap <Right> :bnext<CR>
:nnoremap <Left> :bprevious<CR>
:nnoremap <tab> <c-w><c-w>

if empty(glob('~/.vim/autoload/plug.vim'))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
                \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')
Plug 'vim-pandoc/vim-pandoc'
Plug 'vim-pandoc/vim-pandoc-syntax'
Plug 'brennier/quicktex'
Plug 'junegunn/goyo.vim'
Plug 'alvan/vim-closetag'
call plug#end()
