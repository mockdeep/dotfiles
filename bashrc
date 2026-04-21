export DOT_PATH="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

source "$DOT_PATH/bash/private"
source "$DOT_PATH/bash/completions/tmuxinator"
source "$DOT_PATH/bash/aliases"
source "$DOT_PATH/bash/env"
source "$DOT_PATH/bash/config"
source /usr/share/bash-completion/bash_completion

export PATH="$BIN_PATH:$SCRIPT_PATH:$PATH"

eval "$(mise activate bash)"
