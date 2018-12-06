
# Set up .bashrc
rm ~/.bashrc
echo 'export PS1="\[\033[32m\][\u@\h \w]\n$ \[\033[0m\]"' >> ~/.bashrc

# Set up vim
mkdir ~/.vim/colors
chown -R $USER ~/.vim
chmod -R 775 ~/.vim
(cd ~/.vim/colors ; curl -O https://raw.githubusercontent.com/altercation/vim-colors-solarized/master/colors/solarized.vim)

# Set up tmux
git clone https://github.com/jimeh/tmux-themepack.git ~/.tmux-themepack

# Download dotfiles
yadm clone https://github.com/lbussell/dotfiles.git
