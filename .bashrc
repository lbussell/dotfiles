export PS1="\[\033[32;1m\][\u@\h \w]\n$ \[\033[0m\]"

mkcd () {
  mkdir "$1"
  cd "$1"
}
