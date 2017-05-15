. ~/Dropbox/dotfiles/bash/private
. ~/Dropbox/dotfiles/bash/aliases
. ~/Dropbox/dotfiles/bash/env
. ~/Dropbox/dotfiles/bash/config
. ~/Dropbox/bin/hub.bash_completion.sh
. /usr/share/bash-completion/bash_completion
. /etc/profile.d/rvm.sh

export PATH="/home/fletch/Dropbox/bin:$PATH"

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"

# android studio
export PATH="/usr/local/android-studio/bin:$PATH"
export JAVA_HOME="/usr/lib/jvm/java-8-oracle/"

export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting

# added by travis gem
[ -f /home/fletch/.travis/travis.sh ] && source /home/fletch/.travis/travis.sh

export NVM_DIR="/home/fletch/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

hitch() {
  command hitch "$@"
  if [[ -s "$HOME/.hitch_export_authors" ]] ; then source "$HOME/.hitch_export_authors" ; fi
}
alias unhitch='hitch -u'
