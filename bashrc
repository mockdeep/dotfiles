. ~/Dropbox/dotfiles/bash/private
. ~/Dropbox/dotfiles/bash/aliases
. ~/Dropbox/dotfiles/bash/env
. ~/Dropbox/dotfiles/bash/config

if [[ -s "/usr/local/Cellar/git/1.7.4/etc/bash_completion.d/git-completion.bash" ]]; then
  source "/usr/local/Cellar/git/1.7.4/etc/bash_completion.d/git-completion.bash"
fi

export PATH="~/bin:$PATH"

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"

export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting
