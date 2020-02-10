syntax enable
set t_Co=256
set background=dark
colorscheme gruvbox

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
set wildmenu
set showmatch "show matching ([{}])
set ttimeoutlen=50
set hidden

"Font
set guifont=RobotoMonoForPowerline-Regular:h12

"Searching
set incsearch
set hlsearch
set path+=**

"Move swap file location
set backupdir=~/.vim/backup/
set directory=~/.vim/backup/

"for vimwiki
set nocompatible

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
Plug 'edkolev/tmuxline.vim'
Plug 'scrooloose/nerdtree'
Plug 'vimwiki/vimwiki'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'leafgarland/typescript-vim'
call plug#end()

let g:vimwiki_list = [
                        \{'path': '~/Dropbox\ (Gatech)/cs3600/cs3600.wiki'},
                \]
let g:vimwiki_html_header_numbering = 1

"Airline Settings
let g:airline_powerline_fonts = 1
let g:airline_theme='base16'
