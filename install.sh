#!/bin/bash -e

if ! command -v brew 2>&1 > /dev/null; then
    echo 'Installing homebrew'
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

if ! command -v hub 2>&1 > /dev/null; then
    echo 'Installing hub'
    brew install hub
fi

if [ ! -e /usr/local/bin/zsh ]; then
    echo 'Installing zsh'
    brew install zsh
fi

if dscl . read /Users/$USER UserShell | grep -v '/usr/local/bin/zsh'; then
    echo 'Updating login shell to homebrew zsh'
    sudo dscl . -create /Users/$USER UserShell /usr/local/bin/zsh
fi

if [ ! -d "/${ZDOTDIR:-$HOME}/.zprezto" ]; then
    echo 'Installing prezto'
    git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
fi

echo 'Copying over dot files'
rsync -av --progress -K  files/ ~/

pushd "${ZDOTDIR:-$HOME}"
for rcfile in $(find .zprezto/runcoms -type f | grep -v README.md); do
  FNAME=$(basename "${rcfile}")
   ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${FNAME}" || true
done
popd

if ! crontab -l | grep 'cdp_index.sh' 2>&1 > /dev/null; then
    echo 'Adding crontab for cdp_index'
    echo "*/5 * * * * $HOME/bin/cdp_index.sh $HOME $USER" | crontab -
fi

if ! command -v macvim 2>&1 > /dev/null; then
    echo 'Installing macvim'
    brew install macvim
fi

echo 'Installing Janus for vim'
curl -L https://bit.ly/janus-bootstrap | bash

if ! command -v tmux 2>&1 > /dev/null; then
  echo 'Installing tmux'
  brew install tmux
  brew install reattach-to-user-namespace --with-wrap-pbcopy-and-pbpaste
fi

if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  echo "Installing tmux-plugins"
  git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi

