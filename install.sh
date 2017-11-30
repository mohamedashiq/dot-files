#!/bin/bash -e

echo "Installing environment setup, only missing pieces will be installed."
cmdpresent() {
  command -v "$1" 2>&1 > /dev/null
}

CLR_IDX=-1
colorize_cmd(){

  GREEN="\033[0;32m"
  LT_GREEN="\033[1;32m"
  CYAN="\033[0;36m"
  LT_CYAN="\033[1;36m"
  BLUE="\033[0;34m"
  LT_BLUE="\033[1;34m"
  RED="\033[0;31m"
  LT_RED="\033[1;31m"
  YELLOW="\033[0;33m"
  PURPLE="\033[0;35m"
  LT_PURPLE="\033[1;35m"
  NORMAL="\033[m"
  COLORS=(GREEN CYAN LT_GREEN LT_CYAN BLUE RED LT_BLUE LT_RED PURPLE YELLOW LT_PURPLE)
  COLORS_SIZE=${#COLORS[@]}

  command=$1; shift
  next_color=${1:-$CLR_IDX}
  next_color=$((next_color % COLORS_SIZE))
  color="\$${COLORS[next_color]}"

  # activate color passed as argument
  echo -ne "`eval echo ${color}`"
  # read stdin (pipe) and print from it:
  echo "This color represents stdout of >>>>>> $command"
  cat
  # Note: if instead of reading from the pipe, you wanted to print
  # the additional parameters of the function, you could do:
  # shift; echo $*
  # back to normal (no color)
  echo -ne "${NORMAL}"
}

inc_color() {
  CLR_IDX=$((CLR_IDX=CLR_IDX+1))
}

# myexec("name", command args...)
myexec() {
  local name=$1; shift

  inc_color
  eval "$@" | colorize_cmd "$name" "$CLR_IDX"
}

exec_ifnot_cmd() {
  local cmd=$1; shift
  local name=$1; shift

  if ! cmdpresent "$cmd"; then
    myexec "$name" $@
  else
    myexec "$name" true
  fi
}

exec_ifnot_cmd brew "homebrew install" /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

exec_ifnot_cmd hub "hub install" brew install hub

if [ ! -e /usr/local/bin/zsh ]; then
  myexec 'zsh install' brew install zsh
fi

if dscl . read /Users/$USER UserShell | grep -v '/usr/local/bin/zsh'; then
  myexec "update login shell" sudo dscl . -create /Users/$USER UserShell /usr/local/bin/zsh
fi

if [ ! -d "/${ZDOTDIR:-$HOME}/.zprezto" ]; then
  myexec "prezto install" git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto" 
fi

myexec "rsync dot files" rsync -av -K  --exclude 'iterm2' files/ ~/ 2>&1

inc_color
pushd "${ZDOTDIR:-$HOME}" > /dev/null
for rcfile in $(find .zprezto/runcoms -type f | grep -v README.md); do
  FNAME=$(basename "${rcfile}")
   if [ ! -e "${ZDOTDIR:-$HOME}/.${FNAME}" ]; then
     ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${FNAME}"
   fi
done | colorize_cmd "prezto symlink updates"
popd > /dev/null

inc_color
if ! crontab -l | grep 'cdp_index.sh' 2>&1 > /dev/null; then
    echo "*/5 * * * * $HOME/bin/cdp_index.sh $HOME $USER" | crontab - | colorize_cmd "cdp crontab install"

fi

exec_ifnot_cmd mvim "macvim install"  brew install macvim

inc_color
if [ ! -d "$HOME/.vim/janus" ]; then
  curl -L https://bit.ly/janus-bootstrap | bash | colorize_cmd "janus install"
fi

exec_ifnot_cmd tmux 'tmux install' brew install tmux
exec_ifnot_cmd reattach-to-user-namespace  'reattach-to-user-namespace install' brew install reattach-to-user-namespace --with-wrap-pbcopy-and-pbpaste

inc_color
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  if true; then
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"

    ~/.tmux/plugins/tpm/bin/install_plugins
  fi | colorize_cmd 'tmux-plugin installs'
fi

exec_ifnot_cmd python3 'python3 install' brew install python3

exec_ifnot_cmd pipenv 'pipenv install' pip3 install --user pipenv

exec_ifnot_cmd aws 'aws cli tools install' pip3 install awscli --upgrade --user

exec_ifnot_cmd ag 'ag install (the silver searcher)' brew install the_silver_searcher

if [ ! -d "$HOME/.sdkman" ]; then
  myexec 'install sdkman' 'curl -s "https://get.sdkman.io" | bash'
  source "$HOME/.sdkman/bin/sdkman-init.sh"
fi

exec_ifnot_cmd gradle 'install gradle' sdk install gradle

echo "Install Complete"
