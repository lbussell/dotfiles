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
set mouse=a
set number
set showcmd
set cursorline
filetype indent on
set wildmenu
set showmatch "show matching ([{}])
set ttimeoutlen=50

"Font
set guifont=RobotoMonoForPowerline-Regular:h12

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
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
call plug#end()

"Airline Settings
let g:airline_powerline_fonts = 1
