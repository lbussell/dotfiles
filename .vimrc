syntax on
set t_Co=256

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
set ignorecase
set smartcase
set incsearch
set hlsearch
"set path+e=**

"Move swap file location
set noswapfile
set nobackup

"for vimwiki
set nocompatible

nnoremap <C-x> :bp<Bar>bd #<Cr>
nnoremap <silent> <C-n> :bprev<CR>
nnoremap <silent> <C-p> :bnext<CR>

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
Plug 'ryanoasis/vim-devicons'
Plug 'airblade/vim-gitgutter'
Plug 'Yggdroot/indentLine'
Plug 'vimwiki/vimwiki'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'leafgarland/typescript-vim'
Plug 'arzg/vim-colors-xcode'
Plug 'dracula/vim', {'as': 'dracula'}
Plug 'joshdick/onedark.vim'
Plug 'sheerun/vim-polyglot'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-commentary'
call plug#end()

let g:vimwiki_list = [
                        \{'path': '~/Dropbox\ (Gatech)/cs3600/cs3600.wiki'},
                \]
let g:vimwiki_html_header_numbering = 1

"Airline Settings
let g:airline#extensions#tabline#enabled = 1
let g:airline_powerline_fonts = 1
let g:airline_theme='onedark'

let g:onedark_hide_endofbuffer = 1
let g:onedark_termcolors = 256 
let g:onedark_terminal_italics = 1

set background=dark
colorscheme onedark

hi Normal guibg=NONE ctermbg=NONE

