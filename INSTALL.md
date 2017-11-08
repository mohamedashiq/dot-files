1. Install home brew

1. Install hub `brew install hub`

1. Install newest zsh shell via home brew `brew install zsh`

1. Verify install `/usr/local/bin/zsh --version`

1. Update login shell `chsh -s /usr/local/bin/zsh`

1. install prezto `git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"`

1. Setup prezto: 
```setopt EXTENDED_GLOB
for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
  ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
done
```

1. copy over dot files `cp -a . ~/`

1. install the cron job

1. install janus
