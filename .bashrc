export PS1="\[\033[38;5;10m\][\u@\h \[$(tput sgr0)\]\[\033[38;5;14m\]\w\[$(tput sgr0)\]\[\033[38;5;10m\]]\n\\$ \[$(tput sgr0)\]"

mkcd () {
  mkdir "$1"
  cd "$1"
}
