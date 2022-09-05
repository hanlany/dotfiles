#==============================================================================
# Package install script for vim
#==============================================================================

# Symlink .vimrc to ~
ln -s $(pwd)/.vimrc ~/.vimrc

# Install Pathogen
mkdir -p ~/.vim/autoload ~/.vim/bundle && \
curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim

# Install packages
# Auto pairs
git clone git://github.com/jiangmiao/auto-pairs.git ~/.vim/bundle/auto-pairs

# NERD tree
git clone https://github.com/preservim/nerdtree.git ~/.vim/bundle/nerdtree

# NERD tree git plugin
git clone https://github.com/Xuyuanp/nerdtree-git-plugin.git \
~/.vim/bundle/nerdtree-git-plugin

# Syntastic
git clone --depth=1 https://github.com/vim-syntastic/syntastic.git \
~/.vim/bundle/syntastic

# Lightline
git clone https://github.com/itchyny/lightline.vim ~/.vim/bundle/lightline.vim

# Git gutter
git clone https://github.com/airblade/vim-gitgutter ~/.vim/bundle/vim-gitgutter

# Supertab
git clone https://github.com/ervandew/supertab ~/.vim/bundle/supertab

# Color scheme
git clone https://github.com/flazz/vim-colorschemes ~/.vim/bundle/vim-colorschemes

# Haskell highlighting
git clone https://github.com/neovimhaskell/haskell-vim.git ~/.vim/bundle/haskell-vim

# fzf
git clone https://github.com/junegunn/fzf.vim ~/.vim/bundle/fzf.vim
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

