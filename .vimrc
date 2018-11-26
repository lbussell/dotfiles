syntax enable
set t_Co=256
set background=dark
colorscheme solarized

"Spaces and Tabs
set tabstop=4
set softtabstop=4
set expandtab
set shiftwidth=4

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

call plug#begin('~/.vim/plugged')
Plug 'vim-pandoc/vim-pandoc'
Plug 'vim-pandoc/vim-pandoc-syntax'
Plug 'brennier/quicktex'
Plug 'junegunn/goyo.vim'
call plug#end()
