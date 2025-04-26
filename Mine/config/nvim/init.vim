" From VIM
set runtimepath^=~/.vim runtimepath+=~/.vim/after
" let &packpath = $runtimepath

" Settings
let g:loaded_perl_provider = 0

" VSCode NVIM settings (Linux)
if exists('g:vscode')
    source ~/.vimrcmin
else
    source ~/.vimrc
endif

" source ~/.vimrc
