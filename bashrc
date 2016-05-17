. ~/Dropbox/dotfiles/bash/private
. ~/Dropbox/dotfiles/bash/aliases
. ~/Dropbox/dotfiles/bash/env
. ~/Dropbox/dotfiles/bash/config
. ~/bin/hub.bash_completion.sh

export PATH="~/bin:$PATH"

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"

export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting

# added by travis gem
[ -f /home/fletch/.travis/travis.sh ] && source /home/fletch/.travis/travis.sh

export NVM_DIR="/home/fletch/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm
[[ -s "$HOME/.avn/bin/avn.sh" ]] && source "$HOME/.avn/bin/avn.sh" # load avn

hitch() {
  command hitch "$@"
  if [[ -s "$HOME/.hitch_export_authors" ]] ; then source "$HOME/.hitch_export_authors" ; fi
}
alias unhitch='hitch -u'
