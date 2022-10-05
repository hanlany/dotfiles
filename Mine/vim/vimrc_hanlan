""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""" Pluggin bundle (via vundle)
set nocompatible		" be iMproved, required
filetype off			" required
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" Package manager
Plugin 'gmarik/vundle'

" Color Scheme
Plugin 'joshdick/onedark.vim'
Plugin 'https://github.com/morhetz/gruvbox.git'
Plugin 'crusoexia/vim-monokai'
Plugin 'dracula/vim', { 'name': 'dracula' }
Plugin 'rafi/awesome-vim-colorschemes'

" Vim airline (UI shows VIM status)
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'

" Nerdtree (Filetree navigator)
Plugin 'scrooloose/nerdtree'

" YouCompleteMe (Autocomplete)
"Plugin 'Valloric/YouCompleteMe'

" vim-mark (Multiple highlights via <leader>m)
Plugin 'inkarkat/vim-mark.git'

" vim-ingo-library
Plugin 'inkarkat/vim-ingo-library.git'

" tcomment_vim
" (Autocomment out code via <leader>gc)
" (Do whole line with <leader>gcc)
Plugin 'tomtom/tcomment_vim'

" Multiples (Show location of marks)
Plugin 'jacquesbh/vim-showmarks'

" vim-tmux-navigator (Allow vim keybind to move between tmux pane and vim
" pane)
Plugin 'christoomey/vim-tmux-navigator'

" Arista Related
"Plugin 'https://gitlab.aristanetworks.com/vim-scripts/mts.vim'
"Plugin 'https://gitlab.aristanetworks.com/jlerner/grokfromvim'

call vundle#end()
filetype plugin indent on

" Include the system settings
:if filereadable( '/etc/vimrc' )
    source /etc/vimrc
:endif

" Include Arista-specific settings
:if filereadable( $VIM . '/vimfiles/arista.vim' )
    source $VIM/vimfiles/arista.vim
:endif

" Put your own customizations below

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""" Plugin Setting
"" Airline Setting
let g:airline_powerline_fonts=1

"" NERDTree Setting
let g:NERDTreeDirArrowExpandable = '▸'
let g:NERDTreeDirArrowCollapsible = '▾'
"let g:NERDTreeMinimalUI = 1
let g:NERDTreeShowHidden = 1
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
map <C-n> :NERDTreeToggle<CR>
"" FZF Setting
set rtp+=/usr/local/opt/fzf

"" Prevent langremap breaking plugins
if has('langmap') && exists('+langremap')
    " Prevent that the langmap option applies to characters that result from a
    " mapping. If set (default), this may break plugins (but it's backward
    " compatible).
    set nolangremap
endif

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""" Language Specific
"" Python
let g:pymode_python = 'python'
let g:pymode_trim_whitespaces = 0
let g:pymode_recommended_style = 0
" For Arista python style check
augroup python
    autocmd!
    autocmd FileType python setlocal tabstop=3
    autocmd FileType python setlocal shiftwidth=3
    autocmd FileType python setlocal softtabstop=3
    autocmd FileType python setlocal expandtab
augroup end

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""" General Setting
"" Color scheme + UI
" colorscheme onedark
colorscheme dracula
" colorscheme gruvbox
" colorscheme archery
" colorscheme iceberg
syntax on
set display=truncate
set scrolloff=3

"" Highlight/Search setting
set bg=dark
highlight Normal ctermbg=None
highlight LineNr ctermbg=None
highlight LineNr ctermfg=DarkGrey
"hi Search ctermbg=Yellow ctermfg=Black
set number
set colorcolumn=80
set incsearch
set hlsearch
set ignorecase
set smartcase
" set cursorline

"" Miscellaneous
set mouse=a
noremap <C-c> <Esc>
set backspace=indent,eol,start
set updatetime=250
set showcmd
set history=50
set ruler
set wildmenu " diplay completion matches in status line
set wildmode=longest:list,full

"" Tab setup
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab

"" Indent Mapping
vnoremap > >gv
vnoremap < <gv
nnoremap <Tab> >>_
nnoremap <S-Tab> <<_
inoremap <S-Tab> <C-D>
vnoremap <Tab> >gv
vnoremap <S-Tab> <gv

"" Keybinds to Move arround the windows (tmux+vim)
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

"" Copy and paste
noremap cc "*y
noremap cy "+y
noremap cp "+p

"" Center search results
nnoremap n nzz
nnoremap N Nzz

"" Auto save
"autocmd TextChanged,TextChangedI <buffer> silent write

"" Highligth trailing whitespace
highlight ExtraWhitespace ctermbg=grey guibg=grey
match ExtraWhitespace /\s\+$/

"" Command
" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
" Revert with: ":delcommand DiffOrig".
if !exists(":DiffOrig")
    command DiffOrig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis
            \ | wincmd p | diffthis
endif

"" Source a global configuration file if available
if filereadable('etc/vimrc/local')
    source /etc/vimrc.local
endif
