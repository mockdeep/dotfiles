FILE_ROOT=$HOME/Dropbox

source $FILE_ROOT/dotfiles/bash/private
source $DOT_PATH/bash/aliases
source $DOT_PATH/bash/env
source $DOT_PATH/bash/config
source /usr/share/bash-completion/bash_completion

export PATH="$BIN_PATH:$SCRIPT_PATH:$PATH"

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"

# android studio
export PATH="/usr/local/android-studio/bin:$PATH"
export JAVA_HOME="/usr/lib/jvm/java-8-oracle/"

# added by travis gem
[ -f $HOME/.travis/travis.sh ] && source $HOME/.travis/travis.sh

hitch() {
  command hitch "$@"
  if [[ -s "$HOME/.hitch_export_authors" ]] ; then source "$HOME/.hitch_export_authors" ; fi
}
alias unhitch='hitch -u'

. $HOME/.asdf/asdf.sh
. $HOME/.asdf/completions/asdf.bash
