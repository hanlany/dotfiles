""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""" Plugin Manager - vim-plug
call plug#begin('~/.vim/plugged')

" Color Scheme
Plug 'joshdick/onedark.vim'
Plug 'https://github.com/morhetz/gruvbox.git'
Plug 'crusoexia/vim-monokai'
Plug 'dracula/vim', { 'name': 'dracula' }
Plug 'rafi/awesome-vim-colorschemes'

" Vim airline (UI shows VIM status)
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" Nerdtree (Filetree navigator)
Plug 'scrooloose/nerdtree'

" FZF(fuzzy file finder)
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" Mundo show vim undo history tree
Plug 'simnalamburt/vim-mundo'

" YouCompleteMe (Autocomplete)
"Plug 'Valloric/YouCompleteMe'

" coc.nvim (Alternate Autocomplete)
Plug 'neoclide/coc.nvim', {'branch': 'release' }

" vim plugin for LaTeX
Plug 'lervag/vimtex'

" Code snippet tool (work together with coc-snippets)
Plug 'honza/vim-snippets'
Plug 'SirVer/ultisnips'

" Automatically update tags so you can jump to label easily
Plug 'ludovicchabant/vim-gutentags'

" Handy git functions in vim
Plug 'airblade/vim-gitgutter'

" Plugin to change surround of texts
Plug 'tpope/vim-surround'

" Autoformat plugin
Plug 'vim-autoformat/vim-autoformat'

" vim-mark (Multiple highlights via <leader>m)
Plug 'https://github.com/inkarkat/vim-mark'

" vim-ingo-library
Plug 'https://github.com/inkarkat/vim-ingo-library'

" tcomment_vim
" (Autocomment out code via <leader>gc)
" (Do whole line with <leader>gcc)
Plug 'tomtom/tcomment_vim'

" Multiples (Show location of marks)
Plug 'jacquesbh/vim-showmarks'

" vim-tmux-navigator (Allow vim keybind to move between tmux pane and vim
" pane)
Plug 'christoomey/vim-tmux-navigator'

" Markdown file preview plugin
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() },
            \'for': ['markdown', 'vim-plug']}

" Arista Related
"Plug 'https://gitlab.aristanetworks.com/vim-scripts/mts.vim'
"Plug 'https://gitlab.aristanetworks.com/jlerner/grokfromvim'

call plug#end()


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

"" Mundo Setting
set undofile
set undodir=~/.vim/undo
map <A-u> :MundoToggle<CR>

"" NERDTree Setting
let g:NERDTreeDirArrowExpandable = '▸'
let g:NERDTreeDirArrowCollapsible = '▾'
"let g:NERDTreeMinimalUI = 1
let g:NERDTreeShowHidden = 1
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
map <C-n> :NERDTreeToggle<CR>

"" FZF Setting (from package installed previously from git)
" set rtp+=~/.fzf

"" COC Setting (from github repo)
" Use tab for trigger completion with characters ahead and navigate.
" NOTE: There's always complete item selected by default, you may want to enable
" no select by `"suggest.noselect": true` in your configuration file.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"
function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction
" Make <CR> to accept selected completion item or notify coc.nvim to format
" <C-g>u breaks current undo, please make your own choice.
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
" Use <c-space> to trigger completion.
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif
" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)
" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
" Use K to show documentation in preview window.
nnoremap <silent> K :call ShowDocumentation()<CR>
function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction
" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')
" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)
" Formatting selected code.
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)
augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end
" Applying codeAction to the selected region.
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)
" Remap keys for applying codeAction to the current buffer.
nmap <leader>ac  <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
nmap <leader>qf  <Plug>(coc-fix-current)
" Run the Code Lens action on the current line.
nmap <leader>cl  <Plug>(coc-codelens-action)
" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)
" Remap <C-f> and <C-b> for scroll float windows/popups.
if has('nvim-0.4.0') || has('patch-8.2.0750')
  nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
  inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
  inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
  vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
endif
" Use CTRL-S for selections ranges.
" Requires 'textDocument/selectionRange' support of language server.
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)
" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocActionAsync('format')
" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call     CocAction('fold', <f-args>)
" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocActionAsync('runCommand', 'editor.action.organizeImport')
" Add (Neo)Vim's native statusline support.
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline.
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}
" Mappings for CoCList
" Show all diagnostics.
nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions.
nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
" Show commands.
nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document.
nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols.
nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list.
nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>

"" Autoformat setting
" keymap for autoformat 
noremap <F3> :Autoformat<CR>

"" VimTex Setting
let g:tex_flavor = 'latex'
let g:vimtex_view_method = 'zathura'

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""" Language Specific
"" Python
let g:pymode_python = 'python'
let g:pymode_trim_whitespaces = 0
let g:pymode_recommended_style = 0
" For Arista python style check
" augroup python
"     autocmd!
"     autocmd FileType python setlocal tabstop=3
"     autocmd FileType python setlocal shiftwidth=3
"     autocmd FileType python setlocal softtabstop=3
"     autocmd FileType python setlocal expandtab
" augroup end

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""" General Setting
"" Setting to let vim recognize Alt key (in gnome term) for more details
"" check: https://stackoverflow.com/questions/6778961/alt-key-shortcuts-not-working-on-gnome-terminal-with-vim/10216459#10216459
if empty($TERM_VSCODE)
    let c='a'
    while c <= 'z'
      exec "set <A-".c.">=\e".c
      exec "imap \e".c." <A-".c.">"
      let c = nr2char(1+char2nr(c))
    endw
endif
set ttimeout ttimeoutlen=50

"" Color scheme + UI
" colorscheme onedark
colorscheme dracula
" colorscheme gruvbox
" colorscheme archery
" colorscheme iceberg
syntax on
set display=truncate
set scrolloff=3
set signcolumn=yes

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
" Commented out for coc shift tab for last entry in Autocomplete
" inoremap <S-Tab> <C-D>
vnoremap <Tab> >gv
vnoremap <S-Tab> <gv

"" Keybinds to Move arround the windows (tmux+vim)
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

"" Copy and paste
" Windows and Mac
noremap cc "*y
" Linux
noremap cy "+y
noremap cp "+p

"" Center search results
nnoremap n nzz
nnoremap N Nzz

"" Keybinding to Insert new line without entering insert mode
nnoremap <silent><A-S-j> m`:silent +g/\m^\s*$/d<CR>``:noh<CR>
" Commentd out since conflicted with <S-K> show doc
" nnoremap <silent><A-S-k> m`:silent -g/\m^\s*$/d<CR>``:noh<CR>
nnoremap <silent><A-j> :set paste<CR>m`o<Esc>``:set nopaste<CR>
nnoremap <silent><A-k> :set paste<CR>m`O<Esc>``:set nopaste<CR>

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
