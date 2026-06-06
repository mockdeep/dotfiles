export DOT_PATH="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

source "$DOT_PATH/bash/private"
source "$DOT_PATH/bash/completions/tmuxinator"
source "$DOT_PATH/bash/aliases"
source "$DOT_PATH/bash/env"
source "$DOT_PATH/bash/config"
source /usr/share/bash-completion/bash_completion

export PATH="$BIN_PATH:$SCRIPT_PATH:$PATH"

eval "$(mise activate bash)"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Android SDK
export ANDROID_HOME="$HOME/Android/Sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH"
